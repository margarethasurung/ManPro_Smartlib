import { CONFIG } from "./config.js";
import { makeQrDataUrl } from "./card-scan.js";

const safe = value => String(value ?? "").replace(/[&<>"']/g, char => ({ "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;" }[char]));
const pad2 = value => String(value).padStart(2, "0");
const localISO = date => `${date.getFullYear()}-${pad2(date.getMonth()+1)}-${pad2(date.getDate())}`;
const todayISO = () => localISO(new Date());
const addDays = (iso, days) => { const date = new Date(`${iso}T00:00:00`); date.setDate(date.getDate() + days); return localISO(date); };
const dayLabel = iso => new Date(`${iso}T00:00:00`).toLocaleDateString("id-ID", { weekday: "short", day: "numeric", month: "short" });
const toMinutes = value => { const [hour, minute] = value.split(":").map(Number); return hour * 60 + minute; };
const fromMinutes = value => `${String(Math.floor(value/60)).padStart(2,"0")}:${String(value%60).padStart(2,"0")}`;

export const ROOMS = [
  { id: "ruang-senja", name: "Ruang Senja", capacity: 6, detail: "Ruang diskusi dengan papan tulis." },
  { id: "studio-kata", name: "Studio Kata", capacity: 4, detail: "Studio rekaman dan kegiatan kreatif." },
  { id: "meja-komunal", name: "Meja Komunal", capacity: 10, detail: "Area belajar kolaboratif." },
];

export function createRoomService(store, auth, toast) {
  function sweep() {
    const now = new Date();
    store.update(state => {
      for (const booking of state.roomBookings) {
        if (booking.status !== "aktif" || !booking.mulai) continue;
        const starts = new Date(`${booking.tanggal}T${booking.mulai}:00`);
        if (now.getTime() > starts.getTime() + CONFIG.ROOM_CHECK_IN_GRACE_MINUTES * 60000 && !booking.checkedInAt) {
          booking.status = "hangus";
        }
        const ends = new Date(`${booking.tanggal}T${booking.selesai}:00`);
        if (booking.status === "aktif" && booking.checkedInAt && now > ends) booking.status = "selesai";
      }
      for (const hold of state.holds) {
        if (hold.status === "siap diambil" && hold.expiresAt < todayISO()) {
          hold.status = "kedaluwarsa";
          const book = state.books.find(item=>item.id===hold.bookId);
          if (book) book.available++;
          const next = state.holds.filter(item=>item.bookId===hold.bookId&&item.status==="antre").sort((a,b)=>a.createdAt.localeCompare(b.createdAt))[0];
          if (next) { next.status="siap diambil";next.expiresAt=new Date(Date.now()+CONFIG.TAHAN_RESERVASI_HARI*86400000).toISOString().slice(0,10);if(book)book.available=Math.max(0,book.available-1); }
        }
      }
    });
  }
  function create(formData) {
    const user=auth.getCurrentUser();
    if(!user){location.hash="#/login?kembali=%23%2Frooms";return false;}
    const room=ROOMS.find(item=>item.id===formData.roomId),date=formData.tanggal,start=toMinutes(formData.mulai),end=start+Number(formData.durasi),people=Number(formData.orang);
    if(!room||!Number.isFinite(start)||!CONFIG.ROOM_DURATIONS.includes(Number(formData.durasi))||date<todayISO()||date>addDays(todayISO(),CONFIG.ROOM_BOOKING_MAX_DAYS)){toast("Periksa pilihan ruang, durasi, dan tanggal booking.");return false;}
    const now=new Date();
    if(date===todayISO()&&start<=now.getHours()*60+now.getMinutes()){toast("Jam booking harus berada di waktu mendatang.");return false;}
    if(people<1||people>room.capacity){toast(`Kapasitas ${room.name} maksimal ${room.capacity} orang.`);return false;}
    if(start<CONFIG.OPENING_HOUR*60||end>CONFIG.CLOSING_HOUR*60){toast("Jam booking di luar jam operasional.");return false;}
    const active=store.get().roomBookings.filter(item=>item.userId===user.id&&item.status==="aktif");
    if(active.length>=CONFIG.ROOM_BOOKING_MAX_ACTIVE){toast(`Maksimal ${CONFIG.ROOM_BOOKING_MAX_ACTIVE} booking aktif per anggota.`);return false;}
    const conflict=store.get().roomBookings.some(item=>item.roomId===room.id&&item.tanggal===date&&item.status==="aktif"&&start<toMinutes(item.selesai)&&end>toMinutes(item.mulai));
    if(conflict){const alternatives=suggestions(room.id,date,start,Number(formData.durasi));toast(`Waktu bertabrakan. Slot kosong terdekat: ${alternatives.join(", ")||"tidak ada slot yang cocok."}`);return false;}
    store.update(state=>state.roomBookings.push({id:crypto.randomUUID(),userId:user.id,roomId:room.id,tanggal:date,mulai:formData.mulai,selesai:fromMinutes(end),orang:people,keperluan:String(formData.keperluan).trim(),status:"aktif",kode:`SLR-${crypto.randomUUID().slice(0,8).toUpperCase()}`,createdAt:new Date().toISOString()}));
    toast("Booking ruang berhasil dibuat.");
    return true;
  }
  function cancel(id) {
    const user=auth.getCurrentUser(),booking=store.get().roomBookings.find(item=>item.id===id&&item.userId===user?.id&&item.status==="aktif");
    if(!booking)return;
    const starts=new Date(`${booking.tanggal}T${booking.mulai}:00`);
    if((starts-Date.now())/3600000<CONFIG.ROOM_CANCEL_CUTOFF_HOURS){toast("Booking hanya dapat dibatalkan minimal 1 jam sebelumnya.");return;}
    store.update(state=>{const target=state.roomBookings.find(item=>item.id===id);target.status="dibatalkan";});
    toast("Booking berhasil dibatalkan.");
  }
  function checkIn(id) {
    const booking=store.get().roomBookings.find(item=>item.id===id&&item.status==="aktif");
    if(!booking)return;
    const start=new Date(`${booking.tanggal}T${booking.mulai}:00`),now=Date.now();
    if(now<start.getTime()-15*60000){toast("Check-in tersedia mulai 15 menit sebelum jadwal.");return;}
    if(now>start.getTime()+CONFIG.ROOM_CHECK_IN_GRACE_MINUTES*60000){store.update(state=>{const item=state.roomBookings.find(entry=>entry.id===id);if(item)item.status="hangus";});toast("Batas check-in terlewati; booking ditandai hangus.");return;}
    store.update(state=>{const item=state.roomBookings.find(entry=>entry.id===id);if(item)item.checkedInAt=new Date().toISOString();});
    toast("Check-in booking berhasil.");
  }
  function suggestions(roomId,date,requestedStart,duration){const bookings=store.get().roomBookings.filter(item=>item.roomId===roomId&&item.tanggal===date&&item.status==="aktif"),slots=[];for(let start=CONFIG.OPENING_HOUR*60;start+duration<=CONFIG.CLOSING_HOUR*60;start+=CONFIG.ROOM_SLOT_MINUTES){if(!bookings.some(item=>start<toMinutes(item.selesai)&&start+duration>toMinutes(item.mulai)))slots.push(start);}return slots.sort((a,b)=>Math.abs(a-requestedStart)-Math.abs(b-requestedStart)).slice(0,2).map(fromMinutes);}
  sweep();
  const timer=setInterval(sweep,60000);
  return Object.freeze({cancel,checkIn,create,suggestions,sweep,stop:()=>clearInterval(timer)});
}

export function renderRooms(main,{state,auth,rooms,navigate}) {
  const user=auth.getCurrentUser(),today=todayISO(),maxDate=addDays(today,CONFIG.ROOM_BOOKING_MAX_DAYS);
  const pick={roomId:ROOMS[0].id,tanggal:today,mulai:"",durasi:60};
  const myBookings=state.roomBookings.filter(item=>item.userId===user?.id).sort((a,b)=>`${a.tanggal}${a.mulai}`.localeCompare(`${b.tanggal}${b.mulai}`));
  const chipDays=Array.from({length:7},(_,index)=>addDays(today,index));
  main.innerHTML=`<section class="page"><div class="page-intro"><div><span class="eyebrow">Ruang untuk bertumbuh</span><h1 class="page-title">Pesan tempatmu.</h1><p>Pilih ruang, tanggal, lalu jam. Durasi 30 hingga 120 menit, jam operasional ${String(CONFIG.OPENING_HOUR).padStart(2,"0")}.00–${CONFIG.CLOSING_HOUR}.00.</p></div><span class="pill">${ROOMS.length} ruang tersedia</span></div>
    <div class="dashboard-grid"><section class="panel"><form id="room-form" novalidate>
      <fieldset class="booking-step"><legend><span class="step-no">1</span> Pilih ruang</legend><div class="room-cards">${ROOMS.map((room,index)=>`<label class="room-card"><input type="radio" name="roomId" value="${room.id}" ${index===0?"checked":""}><strong>${safe(room.name)}</strong><small>Maks. ${room.capacity} orang</small><span>${safe(room.detail)}</span></label>`).join("")}</div></fieldset>
      <fieldset class="booking-step"><legend><span class="step-no">2</span> Pilih tanggal</legend><div class="date-chips" role="group" aria-label="Tanggal cepat">${chipDays.map(day=>`<button type="button" class="date-chip" data-date="${day}">${day===today?"Hari ini":dayLabel(day)}</button>`).join("")}</div><label class="field">Atau pilih tanggal lain<input name="tanggal" id="room-date" type="date" min="${today}" max="${maxDate}" value="${today}" required></label></fieldset>
      <fieldset class="booking-step"><legend><span class="step-no">3</span> Pilih jam</legend><label class="field">Durasi<select name="durasi" id="room-duration">${CONFIG.ROOM_DURATIONS.map(minutes=>`<option value="${minutes}" ${minutes===60?"selected":""}>${minutes} menit</option>`).join("")}</select></label><div id="room-timeline" class="slot-groups" aria-live="polite"></div><input type="hidden" name="mulai" id="room-start"></fieldset>
      <fieldset class="booking-step"><legend><span class="step-no">4</span> Detail</legend><label class="field">Jumlah orang<input name="orang" id="room-people" type="number" min="1" max="${ROOMS[0].capacity}" value="2" required></label><label class="field">Keperluan<input name="keperluan" maxlength="120" placeholder="Contoh: diskusi kelompok" required></label></fieldset>
      <p class="booking-summary" id="room-summary" aria-live="polite"></p>
      <button class="primary" id="room-submit">Konfirmasi booking</button><p id="room-error" class="field-error" role="alert"></p></form></section>
    <aside class="panel"><h2>Booking mendatang</h2>${myBookings.filter(item=>item.status==="aktif").map(item=>`<article class="loan-row"><div><strong>${safe(ROOMS.find(room=>room.id===item.roomId)?.name??"Ruang")}</strong><small>${safe(item.tanggal)} · ${safe(item.mulai)}–${safe(item.selesai)} · ${safe(item.orang)} orang</small><small>Kode: ${safe(item.kode)}</small><span class="qr-payload" data-booking-qr="${safe(item.kode)}"></span></div><button class="secondary" data-cancel-booking="${safe(item.id)}">Batalkan</button></article>`).join("")||`<div class="empty">Belum ada booking aktif.</div>`}</aside></div></section>`;
  const form=main.querySelector("#room-form"),dateInput=main.querySelector("#room-date"),duration=main.querySelector("#room-duration"),startInput=main.querySelector("#room-start"),people=main.querySelector("#room-people"),summary=main.querySelector("#room-summary"),submit=main.querySelector("#room-submit"),timeline=main.querySelector("#room-timeline");
  main.querySelectorAll("[data-booking-qr]").forEach(async element=>{try{const source=await makeQrDataUrl(JSON.stringify({t:"booking",id:element.dataset.bookingQr}),80);if(element.isConnected){const image=document.createElement("img");image.src=source;image.alt="QR booking";element.append(image);}}catch(error){console.error("QR booking gagal dibuat",error);element.textContent="QR tidak tersedia";}});
  const GROUPS=[["Pagi",8*60,12*60],["Siang",12*60,15*60],["Sore",15*60,CONFIG.CLOSING_HOUR*60]];
  function slotStatus(time,booked){
    const now=new Date(),nowMinutes=now.getHours()*60+now.getMinutes();
    if(pick.tanggal===today&&time<=nowMinutes)return "Lewat";
    if(time+pick.durasi>CONFIG.CLOSING_HOUR*60)return "Terlalu larut";
    if(booked.some(item=>time<toMinutes(item.selesai)&&time+pick.durasi>toMinutes(item.mulai)))return "Terisi";
    return "";
  }
  function paint(){
    const room=ROOMS.find(item=>item.id===pick.roomId),booked=state.roomBookings.filter(item=>item.roomId===pick.roomId&&item.tanggal===pick.tanggal&&item.status==="aktif");
    const times=Array.from({length:(CONFIG.CLOSING_HOUR-CONFIG.OPENING_HOUR)*60/CONFIG.ROOM_SLOT_MINUTES},(_,index)=>CONFIG.OPENING_HOUR*60+index*CONFIG.ROOM_SLOT_MINUTES);
    if(pick.mulai&&slotStatus(toMinutes(pick.mulai),booked))pick.mulai="";
    if(!pick.mulai){const free=times.find(time=>!slotStatus(time,booked));if(free!==undefined)pick.mulai=fromMinutes(free);}
    timeline.innerHTML=GROUPS.map(([label,from,to])=>`<div class="slot-group"><h3>${label}</h3><div class="room-timeline">${times.filter(time=>time>=from&&time<to).map(time=>{const status=slotStatus(time,booked),selected=fromMinutes(time)===pick.mulai;return `<button type="button" class="room-slot ${status?"occupied":""} ${selected?"selected":""}" ${status?"disabled":""} data-slot="${fromMinutes(time)}" aria-pressed="${selected}" aria-label="${fromMinutes(time)} ${status||"tersedia"}">${fromMinutes(time)}<small>${status||"Kosong"}</small></button>`;}).join("")}</div></div>`).join("");
    timeline.querySelectorAll("[data-slot]").forEach(button=>button.addEventListener("click",()=>{pick.mulai=button.dataset.slot;paint();}));
    main.querySelectorAll(".date-chip").forEach(chip=>chip.classList.toggle("selected",chip.dataset.date===pick.tanggal));
    startInput.value=pick.mulai;people.max=room.capacity;if(Number(people.value)>room.capacity)people.value=room.capacity;
    submit.disabled=!pick.mulai;
    summary.textContent=pick.mulai?`${room.name} · ${dayLabel(pick.tanggal)} · ${pick.mulai}–${fromMinutes(toMinutes(pick.mulai)+pick.durasi)} (${pick.durasi} menit)`:"Tidak ada jam kosong pada pilihan ini. Coba tanggal, ruang, atau durasi lain.";
  }
  form.querySelectorAll('input[name="roomId"]').forEach(radio=>radio.addEventListener("change",()=>{pick.roomId=radio.value;paint();}));
  main.querySelectorAll(".date-chip").forEach(chip=>chip.addEventListener("click",()=>{pick.tanggal=chip.dataset.date;dateInput.value=pick.tanggal;paint();}));
  dateInput.addEventListener("change",()=>{if(dateInput.value)pick.tanggal=dateInput.value;paint();});
  duration.addEventListener("change",()=>{pick.durasi=Number(duration.value);paint();});
  paint();
  form.addEventListener("submit",event=>{
    event.preventDefault();
    const values=Object.fromEntries(new FormData(form).entries());
    if(rooms.create(values))navigate("rooms");
    else{const alternatives=rooms.suggestions(values.roomId,values.tanggal,toMinutes(values.mulai||"08:00"),Number(values.durasi));main.querySelector("#room-error").textContent=alternatives.length?`Coba slot kosong terdekat: ${alternatives.join(" atau ")}.`:"Periksa pilihan ruang, tanggal, jam, jumlah orang, dan ketentuan booking.";}
  });
  main.querySelectorAll("[data-cancel-booking]").forEach(button=>button.addEventListener("click",()=>{rooms.cancel(button.dataset.cancelBooking);navigate("rooms");}));
}
