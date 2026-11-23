## feature/pemesanan-tempat-ui → develop

**Isi:** tampilan pemesanan tempat per langkah: (1) pilih ruang lewat kartu, (2) pilih tanggal (tombol 7 hari + kalender), (3) pilih jam (slot dikelompokkan Pagi/Siang/Sore, slot terisi/bentrok/lewat dinonaktifkan) dan durasi, (4) jumlah orang + keperluan. Ada ringkasan pilihan sebelum konfirmasi.

**Perubahan:** `js/rooms.js` (fungsi `renderRooms`), `styles.css` (bagian akhir).
**Perbaikan:** tanggal "hari ini" sekarang memakai waktu lokal. Sebelumnya memakai UTC sehingga di WIB sebelum pukul 07.00 tanggalnya mundur satu hari.

**Belum:** data masih `localStorage`. Disambungkan ke API `feature/pemesanan-tempat` (Margaretha) setelah endpoint siap; nama field form (`roomId`, `tanggal`, `mulai`, `durasi`, `orang`, `keperluan`) sengaja dipertahankan supaya mudah dipetakan.

**Cara tes:** `cd frontend && php -S localhost:8000`, login, buka `#/rooms`, coba pilih ruang/tanggal/jam, durasi 120 menit, dan buat dua booking yang bentrok.
