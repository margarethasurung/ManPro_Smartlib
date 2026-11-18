import { createAuth } from "./js/auth.js";
import { renderAdmin } from "./js/admin.js";
import { renderAI } from "./js/ai.js";
import { bookCard, renderBook, renderCatalog, renderFavorites } from "./js/catalog.js";
import { renderCard, renderScan } from "./js/card-scan.js";
import { renderEvents, renderSuggestions } from "./js/community.js?v=vertical-layout-1";
import { createLoanService, renderLoans } from "./js/loans.js";
import { renderJournal, renderPassport } from "./js/reading.js";
import { renderReader } from "./js/reader.js";
import { renderRooms, createRoomService } from "./js/rooms.js";
import { setupShell } from "./js/shell.js";
import { createInitialState, createStore } from "./js/store.js";

const main=document.querySelector("#main"),toastNode=document.querySelector("#toast");
const toast=message=>{toastNode.textContent=message;toastNode.classList.add("visible");clearTimeout(toastNode.timer);toastNode.timer=setTimeout(()=>toastNode.classList.remove("visible"),3200);};
let store,auth,loans,rooms,shell;

function closeMobileMenu(){const nav=document.querySelector("#nav"),button=document.querySelector("#menu-button");nav?.classList.remove("open");button?.setAttribute("aria-expanded","false");button?.setAttribute("aria-label","Buka menu");}
function navigate(route){const destination=route.startsWith("#/")?route:`#/${route}`,unchanged=location.hash===destination;document.querySelector("#profile-menu").hidden=true;closeMobileMenu();if(unchanged)render();else location.hash=destination;}
function routeParts(){
  const raw=location.hash.slice(2)||"home",split=raw.split("?"),path=decodeURIComponent(split[0]||"home");
  return {path:path==="spaces"?"rooms":path==="assistant"?"ai":path,params:new URLSearchParams(split.slice(1).join("?"))};
}

function renderHome(state){
  const user=auth.getCurrentUser(),featured=[...state.books].sort((a,b)=>b.rating-a.rating).slice(0,5),events=state.events.filter(event=>event.tanggal>=new Date().toISOString().slice(0,10)).sort((a,b)=>a.tanggal.localeCompare(b.tanggal)).slice(0,3),announcement=state.announcements.find(item=>item.active!==false&&!store.get().dismissedAnnouncements?.includes(item.id));
  main.innerHTML=`<section class="hero"><div class="hero-copy"><span class="eyebrow">Perpustakaan · ruang tumbuh</span><h1>Temukan cerita <em>berikutnya.</em></h1><p>Jelajahi koleksi, pinjam buku, pesan ruang belajar, dan temukan bacaan yang sesuai suasana hatimu.</p><form class="searchbar" id="home-search"><span aria-hidden="true">⌕</span><label class="screen-reader" for="home-query">Cari buku</label><input id="home-query" placeholder="Cari judul, penulis, atau ISBN"><button type="submit">Jelajahi</button></form></div><div class="hero-art"><div class="quote">“Membaca adalah perjalanan yang selalu menemukan jalan pulang.”<small>SmartLib · ruang tumbuh bersama</small></div><div class="book-stack">${featured.slice(0,3).map(book=>`<a href="#/book/${encodeURIComponent(book.id)}" aria-label="${escapeHtml(book.title)}"><img class="stack-cover" src="${book.coverUrl??(book.coverId?`https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg`:`https://covers.openlibrary.org/b/isbn/${book.isbn}-M.jpg`)}" alt="Sampul ${escapeHtml(book.title)}"></a>`).join("")}</div></div></section>
  ${announcement?`<aside class="announcement" id="announcement"><div><strong>${escapeHtml(announcement.title)}</strong><p>${escapeHtml(announcement.message)}</p></div><button class="close" id="dismiss-announcement" aria-label="Tutup pengumuman">×</button></aside>`:""}
  <section class="section"><div class="section-head"><div><span class="eyebrow">Pilihan pustakawan</span><h2>Buku yang banyak disukai</h2><p>Koleksi bacaan pilihan SmartLib.</p></div><a class="text-link" href="#/catalog">Lihat katalog →</a></div><div class="book-grid">${featured.map(book=>bookCard(book,state)).join("")}</div></section>
  <section class="section agenda-widget"><div class="section-head"><div><span class="eyebrow">Agenda minggu ini</span><h2>Berjumpa dan berbagi.</h2></div><a class="text-link" href="#/events">Semua acara →</a></div><div class="community-grid">${events.map(event=>`<article class="panel"><span class="pill">${escapeHtml(event.tipe)}</span><h3>${escapeHtml(event.judul)}</h3><p>${new Date(`${event.tanggal}T${event.jam}`).toLocaleString("id-ID",{dateStyle:"medium",timeStyle:"short"})} · ${escapeHtml(event.lokasi)}</p><a class="text-link" href="#/events">Detail & RSVP →</a></article>`).join("")||"<p>Belum ada acara mendatang.</p>"}</div></section>
  <section class="feature-strip"><a href="#/rooms"><strong>Pesan ruang belajar</strong><span>Atur jadwal ruang diskusi.</span></a><a href="#/ai"><strong>Pustakawan AI</strong><span>Temukan rekomendasi lokal.</span></a><a href="${user?"#/passport":"#/register"}"><strong>Paspor membaca</strong><span>Bangun perjalanan membaca.</span></a></section>
  <p class="home-account">${user?`Selamat datang, ${escapeHtml(user.nama)}.`:`Anggota demo: nadia@smartlib.id · Nadia12345 &nbsp; Pustakawan: pustakawan@smartlib.id · Pustakawan12345 &nbsp; Manajemen: manajemen@smartlib.id · Manajemen12345`}</p>`;
  main.querySelector("#home-search").onsubmit=event=>{event.preventDefault();navigate(`catalog?q=${encodeURIComponent(main.querySelector("#home-query").value.trim())}`);};
  main.querySelector("#dismiss-announcement")?.addEventListener("click",()=>{store.update(current=>{current.dismissedAnnouncements??=[];current.dismissedAnnouncements.push(announcement.id);});render();});
}

function escapeHtml(value){return String(value??"").replace(/[&<>"']/g,char=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[char]));}

function renderAuth(register=false,returnPath=""){
  main.innerHTML=register?`<section class="page auth-page"><div class="panel auth-panel"><span class="eyebrow">Gabung komunitas</span><h1 class="page-title">Buat akun SmartLib.</h1><p class="auth-copy">Daftar untuk menyimpan koleksi dan perjalanan membaca.</p><form id="auth-form" novalidate><label class="field" for="auth-name">Nama lengkap<input id="auth-name" name="nama" autocomplete="name" required><span class="field-error" id="error-nama" role="alert"></span></label><label class="field" for="auth-email">Email<input id="auth-email" name="email" type="email" autocomplete="email" required><span class="field-error" id="error-email" role="alert"></span></label><label class="field" for="auth-password">Kata sandi<input id="auth-password" name="password" type="password" autocomplete="new-password" minlength="8" required><span class="field-error" id="error-password" role="alert"></span></label><label class="field" for="auth-confirm">Konfirmasi kata sandi<input id="auth-confirm" name="konfirmasi" type="password" required><span class="field-error" id="error-konfirmasi" role="alert"></span></label><p class="field-error" id="form-error" role="alert"></p><button class="primary">Buat akun</button></form><p class="auth-switch">Sudah punya akun? <a class="text-link" href="#/login">Masuk</a></p></div></section>`:
  `<section class="page auth-page"><div class="panel auth-panel"><span class="eyebrow">Selamat datang kembali</span><h1 class="page-title">Masuk ke SmartLib.</h1><p class="auth-copy">Akun demo member: <strong>nadia@smartlib.id</strong> · <strong>Nadia12345</strong><br>Pustakawan: <strong>pustakawan@smartlib.id</strong> · <strong>Pustakawan12345</strong><br>Manajemen: <strong>manajemen@smartlib.id</strong> · <strong>Manajemen12345</strong></p><form id="auth-form" novalidate><label class="field" for="auth-email">Email<input id="auth-email" name="email" type="email" autocomplete="email" required><span class="field-error" id="error-email" role="alert"></span></label><label class="field" for="auth-password">Kata sandi<input id="auth-password" name="password" type="password" autocomplete="current-password" required><span class="field-error" id="error-password" role="alert"></span></label><p class="field-error" id="form-error" role="alert"></p><button class="primary">Masuk</button></form><p class="auth-switch">Belum punya akun? <a class="text-link" href="#/register">Daftar</a></p></div></section>`;
  main.querySelector("#auth-form").onsubmit=async event=>{
    event.preventDefault();main.querySelectorAll(".field-error").forEach(element=>element.textContent="");
    const values=Object.fromEntries(new FormData(event.currentTarget).entries());
    try{
      if(register){const result=await auth.register(values);if(result.errors){for(const [field,message] of Object.entries(result.errors))main.querySelector(`#error-${field}`).textContent=message;return;}await auth.login(values.email,values.password);}
      else {if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email))main.querySelector("#error-email").textContent="Masukkan alamat email yang valid.";if(!values.password)main.querySelector("#error-password").textContent="Kata sandi wajib diisi.";if(main.querySelector("#error-email").textContent||main.querySelector("#error-password").textContent)return;const result=await auth.login(values.email,values.password);if(result.error){main.querySelector("#form-error").textContent=result.error;return;}returnPath=result.returnPath||returnPath;}
      shell.updateMenu();navigate(returnPath.startsWith("#/")?returnPath:"#/home");
    }catch(error){console.error("Autentikasi gagal",error);main.querySelector("#form-error").textContent=error.message||"Permintaan autentikasi gagal. Coba lagi.";}
  };
}

function renderProfile(){
  const user=auth.getCurrentUser();
  main.innerHTML=`<section class="page"><div class="page-intro"><div><span class="eyebrow">Akun anggota</span><h1 class="page-title">Profil SmartLib.</h1><p>Informasi akun yang sedang masuk.</p></div><a class="primary" href="#/card">Buka kartu digital</a></div><div class="panel auth-panel"><h2>${escapeHtml(user.nama)}</h2><p>Email: ${escapeHtml(user.email)}</p><p>Nomor anggota: ${escapeHtml(user.memberId)}</p><p>Peran: ${({pustakawan:"Pustakawan",manajemen:"Manajemen"})[user.role]??"Anggota"}</p><p>Bergabung: ${new Date(user.createdAt).toLocaleDateString("id-ID",{dateStyle:"long"})}</p></div></section>`;
}

function renderNotFound(){
  main.innerHTML=`<section class="page"><div class="empty"><span class="eyebrow">404 · halaman tidak ditemukan</span><h1 class="page-title">Jalannya mungkin terselip.</h1><p>Rute SmartLib ini tidak tersedia.</p><a class="primary" href="#/home">Kembali ke beranda</a></div></section>`;
}

function render(){
  if(!store)return;
  closeMobileMenu();
  const {path,params}=routeParts(),user=auth.getCurrentUser(),protectedRoutes=new Set(["loans","card","favorites","journal","passport","scan"]);
  if((protectedRoutes.has(path)||path.startsWith("reader/"))&&!user){navigate(`login?kembali=${encodeURIComponent(location.hash||"#/home")}`);return;}
  if((path==="admin"||path==="admin/scan")&&!user){navigate(`login?kembali=${encodeURIComponent(location.hash||"#/admin")}`);return;}
  if(path==="admin"&&!["pustakawan","manajemen"].includes(user.role)||path==="admin/scan"&&user.role!=="pustakawan"){toast("Halaman ini hanya untuk Pustakawan atau Manajemen.");navigate("home");return;}
  const state=store.get();
  document.querySelectorAll("[data-route]").forEach(button=>button.classList.toggle("active",button.dataset.route===path||(path==="catalog"&&button.dataset.route==="catalog")));
  try{
    if(path==="home")renderHome(state);
    else if(path==="catalog")renderCatalog(main,{state,navigate,route:{params}});
    else if(path.startsWith("book/"))renderBook(main,{state,auth,bookId:path.slice(5),store,borrow:loans.borrow,toast});
    else if(path==="rooms")renderRooms(main,{state,auth,rooms,navigate});
    else if(path==="loans")renderLoans(main,{state,auth,loans,toast,navigate});
    else if(path==="card")renderCard(main,{auth,toast});
    else if(path==="ai")renderAI(main,{state,auth,store,toast});
    else if(path==="favorites")renderFavorites(main,{state,auth});
    else if(path==="events")renderEvents(main,{state,auth,store,toast,navigate});
    else if(path==="suggest")renderSuggestions(main,{state,auth,store,toast,navigate});
    else if(path==="passport")renderPassport(main,{state,auth,store,toast});
    else if(path==="journal")renderJournal(main,{state,auth,store,toast});
    else if(path==="scan")renderScan(main,{state,auth,loans,toast});
    else if(path.startsWith("reader/"))renderReader(main,{state,auth,bookId:path.slice(7)});
    else if(path==="admin")renderAdmin(main,{state,store,toast,loans,rooms,user,initialTab:params.get("tab")||"Buku"});
    else if(path==="admin/scan")renderScan(main,{state,auth,loans,rooms,toast,admin:true});
    else if(path==="login")renderAuth(false,params.get("kembali")||"");
    else if(path==="register")renderAuth(true,params.get("kembali")||"");
    else if(path==="profile"&&user)renderProfile();
    else renderNotFound();
  }catch(error){console.error(`Halaman ${path} gagal ditampilkan`,error);main.innerHTML=`<section class="page"><div class="empty" role="alert"><h1>Halaman tidak dapat ditampilkan</h1><p>${escapeHtml(error.message||"Terjadi kesalahan saat memuat data.")}</p><button class="primary" id="retry-render">Coba lagi</button></div></section>`;main.querySelector("#retry-render").onclick=render;}
  shell?.notify();
}

async function start(){
  try{
    store=createStore(createInitialState());auth=createAuth(store);await auth.ensureDemoAccounts();
    loans=createLoanService(store,auth,toast);rooms=createRoomService(store,auth,toast);
    shell=setupShell({store,auth,navigate});
    document.querySelectorAll("[data-route]").forEach(button=>button.addEventListener("click",()=>navigate(button.dataset.route)));
    document.querySelector("#menu-button").onclick=event=>{const nav=document.querySelector("#nav"),open=nav.classList.toggle("open");event.currentTarget.setAttribute("aria-expanded",String(open));event.currentTarget.setAttribute("aria-label",open?"Tutup menu":"Buka menu");};
    window.addEventListener("hashchange",render);window.addEventListener("storage",render);
    globalThis.smartlibBorrow=bookId=>{loans.borrow(bookId);render();};
    if(!location.hash)location.hash="#/home";else render();
  }catch(error){console.error("SmartLib gagal dimulai",error);main.innerHTML=`<section class="page"><div class="empty" role="alert"><h1>SmartLib belum dapat dibuka</h1><p>${escapeHtml(error.message||"Terjadi kesalahan saat menyiapkan penyimpanan lokal.")}</p><button class="primary" onclick="location.reload()">Muat ulang</button></div></section>`;}
}

start();
