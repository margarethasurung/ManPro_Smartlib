-- =====================================================================
-- SmartLib - Data Awal (seed)  |  Jalankan SETELAH schema.sql
--   mysql -u root -p smartlib < database/seed.sql
-- Isi: pengaturan aturan bisnis, akun pustakawan + manajemen + 1 anggota demo,
--      kategori, 52 buku (dari js/catalog-data.js), 3 ruang, 3 acara.
-- Password akun demo (HANYA untuk pengembangan, ganti sebelum dipakai sungguhan):
--      pustakawan@smartlib.id  / Pustaka12345     (role pustakawan)
--      manajemen@smartlib.id   / Manajemen12345   (role manajemen)
--      nadia@smartlib.id       / Nadia12345       (role anggota)
-- Hash di bawah dibuat dengan bcrypt ($2y$, cost 10) -> cocok dengan
-- password_verify() PHP. Jangan simpan password asli di database.
-- =====================================================================
USE smartlib;
SET NAMES utf8mb4;

-- Aturan bisnis (nilai sama dengan js/config.js)
INSERT INTO pengaturan (kunci, nilai, keterangan) VALUES
('maks_pinjam',           '4',    'Maksimal buku dipinjam aktif per anggota'),
('lama_pinjam_hari',      '7',    'Lama pinjam awal (hari)'),
('perpanjang_maks',       '2',    'Maksimal perpanjangan per pinjaman'),
('perpanjang_hari',       '7',    'Tambahan hari tiap perpanjangan'),
('denda_per_hari',        '1000', 'Denda keterlambatan (Rupiah per hari)'),
('tahan_reservasi_hari',  '2',    'Lama buku reservasi ditahan setelah siap diambil'),
('booking_maks_hari',     '14',   'Booking ruang maksimal H+14'),
('booking_maks_aktif',    '2',    'Booking aktif maksimal per anggota'),
('booking_batal_jam',     '1',    'Pembatalan booking minimal 1 jam sebelum mulai'),
('booking_checkin_menit', '15',   'Toleransi check-in; lewat dari ini booking hangus'),
('jam_buka',              '8',    'Jam buka perpustakaan'),
('jam_tutup',             '20',   'Jam tutup perpustakaan');

-- Akun staf & demo
INSERT INTO pengguna (id_anggota, nama, email, password_hash, role) VALUES
('ST-0001',      'Pustakawan SmartLib', 'pustakawan@smartlib.id', '$2y$10$/2.yIW083o/LPRznUpPuUu5ugGcDuhLV0b.YyFmT6D7.p/aqBmFKC', 'pustakawan'),
('ST-0002',      'Manajemen SmartLib',  'manajemen@smartlib.id',  '$2y$10$IhI7pO9uChBcHQIfnv4eM.iVkt3BybLsGiaxohi3VlpQiG0nGAT9u', 'manajemen'),
('SL-2026-0001', 'Nadia Putri',         'nadia@smartlib.id',      '$2y$10$mHUUuPpdr9ptpcTZaEKLf.49EcY4BoQzUVkV7rjbWYjKaqrrzItje', 'anggota');

-- Kategori
INSERT INTO kategori (nama) VALUES
('Fiksi'),
('Filsafat'),
('Pengembangan diri'),
('Sejarah'),
('Psikologi'),
('Desain'),
('Fiksi ilmiah'),
('Fiksi sejarah'),
('Fiksi distopia'),
('Fiksi klasik'),
('Fantasi'),
('Fabel'),
('Fiksi satir'),
('Memoar'),
('Fiksi gotik'),
('Thriller'),
('Sains'),
('Lingkungan'),
('Sains & biografi');

-- Buku (stok tersedia = total eksemplar karena belum ada peminjaman)
INSERT INTO buku (kode_buku, judul, penulis, kategori_id, tahun_terbit, penerbit, isbn, jumlah_halaman, deskripsi, cover_id, cover_url, sumber_url, tingkat_baca, lantai, rak, baris, total_eksemplar, tersedia) VALUES
('B101','Laut Bercerita','Leila S. Chudori',(SELECT id FROM kategori WHERE nama='Fiksi'),2017,'Kepustakaan Populer Gramedia','9786024246945',379,'Kisah tentang kehilangan, persahabatan, dan suara-suara yang berusaha tetap hidup. Sebuah perjalanan emosional menembus ingatan dan sejarah.',10648285,NULL,'https://openlibrary.org/search?q=Laut%20Bercerita%20Leila%20S.%20Chudori','sedang',2,'B3',2,3,3),
('B102','Filosofi Teras','Henry Manampiring',(SELECT id FROM kategori WHERE nama='Filsafat'),2018,'Penerbit Buku Kompas','9786233463034',320,'Pengantar filsafat Stoa yang dekat dengan keseharian. Belajar memilah hal yang dapat dikendalikan dan menemukan ruang tenang di tengah hiruk pikuk.',15255806,NULL,'https://openlibrary.org/search?q=Filosofi%20Teras%20Henry%20Manampiring','sedang',2,'B3',2,4,4),
('B103','Atomic Habits','James Clear',(SELECT id FROM kategori WHERE nama='Pengembangan diri'),2018,'Avery','9780735211292',352,'Panduan praktis membangun kebiasaan kecil yang konsisten dan menghasilkan perubahan besar dari waktu ke waktu.',12539702,NULL,'https://openlibrary.org/search?q=Atomic%20Habits%20James%20Clear','sedang',2,'B3',2,3,3),
('B104','Bumi Manusia','Pramoedya Ananta Toer',(SELECT id FROM kategori WHERE nama='Fiksi'),1980,'Gramedia Pustaka Utama','9789799731234',535,'Novel tentang Minke, seorang pribumi terpelajar yang berhadapan dengan ketidakadilan kolonial dan menemukan kekuatan pengetahuan.',6643692,NULL,'https://openlibrary.org/search?q=Bumi%20Manusia%20Pramoedya%20Ananta%20Toer','berat',2,'B3',2,2,2),
('B105','Sapiens','Yuval Noah Harari',(SELECT id FROM kategori WHERE nama='Sejarah'),2011,'Harper','9780062316097',498,'Kisah luas perjalanan manusia dari masa purba hingga dunia modern, disajikan melalui pertanyaan-pertanyaan besar tentang peradaban.',8634250,NULL,'https://openlibrary.org/search?q=Sapiens%20Yuval%20Noah%20Harari','berat',2,'B3',2,3,3),
('B106','Pulang','Tere Liye',(SELECT id FROM kategori WHERE nama='Fiksi'),2015,'Republika Penerbit','9786020822129',400,'Petualangan tentang keluarga, kesetiaan, dan perjalanan menemukan arti pulang di tengah dunia yang penuh kejutan.',12905869,NULL,'https://openlibrary.org/search?q=Pulang%20Tere%20Liye','sedang',2,'B3',2,4,4),
('B107','Laskar Pelangi','Andrea Hirata',(SELECT id FROM kategori WHERE nama='Fiksi'),2005,'Bentang Pustaka','9789793062792',529,'Semangat sepuluh anak Belitung dan guru-guru mereka yang berjuang menjaga mimpi melalui pendidikan.',7079796,NULL,'https://openlibrary.org/search?q=Laskar%20Pelangi%20Andrea%20Hirata','berat',2,'B3',2,3,3),
('B108','Berani Tidak Disukai','Ichiro Kishimi & Fumitake Koga',(SELECT id FROM kategori WHERE nama='Psikologi'),2013,'Gramedia Pustaka Utama','9786020633213',288,'Dialog tentang psikologi Adler, kebebasan menentukan hidup, dan keberanian untuk menjadi diri sendiri.',NULL,'https://cdn.gramedia.com/uploads/items/9786020633213.jpg','https://www.gramedia.com/products/berani-tidak-disukai','ringan',2,'B3',2,2,2),
('B109','The Design of Everyday Things','Don Norman',(SELECT id FROM kategori WHERE nama='Desain'),2013,'Basic Books','9780465050659',368,'Buku klasik tentang bagaimana desain yang baik menjadikan benda sehari-hari lebih mudah dipahami dan digunakan.',10007224,NULL,'https://openlibrary.org/search?q=The%20Design%20of%20Everyday%20Things%20Don%20Norman','sedang',2,'B3',2,2,2),
('B110','Pulang Pergi','Tere Liye',(SELECT id FROM kategori WHERE nama='Fiksi'),2021,'Sabak Grip','9786239554521',414,'Kelanjutan kisah penuh aksi, persahabatan, dan pilihan-pilihan yang mengubah arah perjalanan.',14541785,NULL,'https://openlibrary.org/search?q=Pulang%20Pergi%20Tere%20Liye','sedang',2,'B3',2,2,2),
('B111','Thinking, Fast and Slow','Daniel Kahneman',(SELECT id FROM kategori WHERE nama='Psikologi'),2011,'Farrar, Straus and Giroux','9780374533557',499,'Penjelasan menarik tentang dua sistem berpikir manusia dan bagaimana keduanya memengaruhi keputusan.',13290711,NULL,'https://openlibrary.org/search?q=Thinking%2C%20Fast%20and%20Slow%20Daniel%20Kahneman','berat',2,'B3',2,2,2),
('B112','Anak Semua Bangsa','Pramoedya Ananta Toer',(SELECT id FROM kategori WHERE nama='Fiksi'),1980,'Hasta Mitra',NULL,539,'Kelanjutan perjalanan Minke dalam memahami bangsanya, bahasa, dan tanggung jawab terhadap perubahan.',6635926,NULL,'https://openlibrary.org/search?q=Anak%20Semua%20Bangsa%20Pramoedya%20Ananta%20Toer','berat',2,'B3',2,2,2),
('B113','Negeri 5 Menara','Ahmad Fuadi',(SELECT id FROM kategori WHERE nama='Fiksi'),2009,'Gramedia Pustaka Utama','9789792248616',NULL,'Enam santri di Pondok Madani menjaga persahabatan dan cita-cita mereka dengan keyakinan bahwa usaha sungguh-sungguh akan menemukan jalan.',14303993,NULL,'https://openlibrary.org/search?q=Negeri%205%20Menara%20Ahmad%20Fuadi','sedang',2,'B3',2,2,2),
('B114','Ronggeng Dukuh Paruk','Ahmad Tohari',(SELECT id FROM kategori WHERE nama='Fiksi'),1982,'Gramedia Pustaka Utama','9789792201963',NULL,'Trilogi tentang Srintil, tradisi ronggeng, dan kehidupan masyarakat Dukuh Paruk di tengah perubahan sosial dan sejarah.',4317176,NULL,'https://openlibrary.org/search?q=Ronggeng%20Dukuh%20Paruk%20Ahmad%20Tohari','sedang',2,'B3',2,2,2),
('B115','Perahu Kertas','Dee Lestari',(SELECT id FROM kategori WHERE nama='Fiksi'),2009,'Bentang Pustaka',NULL,NULL,'Kugy dan Keenan menempuh jalan masing-masing sambil merawat mimpi, persahabatan, dan perasaan yang tumbuh perlahan.',8705088,NULL,'https://openlibrary.org/search?q=Perahu%20Kertas%20Dee%20Lestari','sedang',2,'B3',2,2,2),
('B116','Cantik Itu Luka','Eka Kurniawan',(SELECT id FROM kategori WHERE nama='Fiksi'),2002,'Gramedia Pustaka Utama',NULL,NULL,'Novel lintas generasi yang memadukan sejarah, keluarga, mitos, dan kehidupan sebuah kota fiktif di Indonesia.',14846592,NULL,'https://openlibrary.org/search?q=Cantik%20Itu%20Luka%20Eka%20Kurniawan','sedang',2,'B3',2,2,2),
('B117','Lelaki Harimau','Eka Kurniawan',(SELECT id FROM kategori WHERE nama='Fiksi'),2004,'Gramedia Pustaka Utama',NULL,NULL,'Kisah tragis sebuah keluarga dan desa yang dibuka melalui peristiwa kekerasan, kenangan, dan rahasia lama.',13531939,NULL,'https://openlibrary.org/search?q=Lelaki%20Harimau%20Eka%20Kurniawan','sedang',2,'B3',2,2,2),
('B118','Gadis Kretek','Ratih Kumala',(SELECT id FROM kategori WHERE nama='Fiksi'),2012,'Gramedia Pustaka Utama',NULL,NULL,'Kisah keluarga pengusaha kretek, pencarian masa lalu, dan perjalanan cinta yang terjalin dengan sejarah industri rokok Indonesia.',NULL,NULL,'https://openlibrary.org/search?q=Gadis%20Kretek%20Ratih%20Kumala','sedang',2,'B3',2,2,2),
('B119','Seporsi Mie Ayam Sebelum Mati','Brian Khrisna',(SELECT id FROM kategori WHERE nama='Fiksi'),2025,'Grasindo',NULL,NULL,'Novel Indonesia karya Brian Khrisna; edisi katalog mencatat Grasindo sebagai penerbit.',15268683,NULL,'https://openlibrary.org/search?q=Seporsi%20Mie%20Ayam%20Sebelum%20Mati%20Brian%20Khrisna','sedang',2,'B3',2,2,2),
('B120','Hujan','Tere Liye',(SELECT id FROM kategori WHERE nama='Fiksi ilmiah'),2018,'Gramedia Pustaka Utama',NULL,NULL,'Lail menjalani kehidupan di masa depan yang berubah karena bencana alam, teknologi, persahabatan, dan kenangan.',10872657,NULL,'https://openlibrary.org/search?q=Hujan%20Tere%20Liye','sedang',2,'B3',2,2,2),
('B121','Rindu','Tere Liye',(SELECT id FROM kategori WHERE nama='Fiksi sejarah'),2014,'Republika Penerbit',NULL,NULL,'Kisah para penumpang kapal haji pada masa kolonial, dengan perjalanan panjang yang mempertemukan rahasia dan kerinduan.',14541663,NULL,'https://openlibrary.org/search?q=Rindu%20Tere%20Liye','sedang',2,'B3',2,2,2),
('B122','5 cm','Donny Dhirgantoro',(SELECT id FROM kategori WHERE nama='Fiksi'),2005,'Gramedia Widiasarana Indonesia',NULL,NULL,'Lima sahabat mengambil jarak dari rutinitas dan menguji persahabatan serta tekad mereka dalam perjalanan mendaki Semeru.',NULL,NULL,'https://openlibrary.org/search?q=5%20cm%20Donny%20Dhirgantoro','sedang',2,'B3',2,2,2),
('B123','Negeri Para Bedebah','Tere Liye',(SELECT id FROM kategori WHERE nama='Fiksi'),2012,'Gramedia Pustaka Utama',NULL,NULL,'Novel thriller politik dan ekonomi tentang Thomas, seorang konsultan keuangan yang menghadapi krisis dan konspirasi.',14829675,NULL,'https://openlibrary.org/search?q=Negeri%20Para%20Bedebah%20Tere%20Liye','sedang',2,'B3',2,2,2),
('B124','Sang Pemimpi','Andrea Hirata',(SELECT id FROM kategori WHERE nama='Fiksi'),2006,'Bentang Pustaka',NULL,NULL,'Kelanjutan kisah Ikal dan Arai yang mengejar pendidikan serta mimpi mereka jauh dari kampung halaman.',15218349,NULL,'https://openlibrary.org/search?q=Sang%20Pemimpi%20Andrea%20Hirata','sedang',2,'B3',2,2,2),
('B125','Ayah','Andrea Hirata',(SELECT id FROM kategori WHERE nama='Fiksi'),2015,'Bentang Pustaka',NULL,NULL,'Novel tentang Sabari, cinta, persahabatan, dan ikatan seorang ayah dengan anaknya.',NULL,NULL,'https://openlibrary.org/search?q=Ayah%20Andrea%20Hirata','sedang',2,'B3',2,2,2),
('B126','Hujan Bulan Juni','Sapardi Djoko Damono',(SELECT id FROM kategori WHERE nama='Fiksi'),1994,'Gramedia Widiasarana Indonesia',NULL,NULL,'Novel yang mengembangkan kisah cinta Pingkan dan Sarwono, dengan latar perjalanan, keluarga, dan perbedaan budaya.',10057126,NULL,'https://openlibrary.org/search?q=Hujan%20Bulan%20Juni%20Sapardi%20Djoko%20Damono','sedang',2,'B3',2,2,2),
('B127','1984','George Orwell',(SELECT id FROM kategori WHERE nama='Fiksi distopia'),1949,'Signet Classics','9780451524935',NULL,'Novel distopia tentang Winston Smith yang hidup di bawah pengawasan negara totaliter dan kendali atas informasi.',9267242,NULL,'https://openlibrary.org/search?q=1984%20George%20Orwell','sedang',2,'B3',2,2,2),
('B128','To Kill a Mockingbird','Harper Lee',(SELECT id FROM kategori WHERE nama='Fiksi'),1960,'J. B. Lippincott & Co.',NULL,NULL,'Kisah Scout Finch di Alabama yang menyentuh isu keadilan, prasangka, dan tumbuh dewasa.',14351077,NULL,'https://openlibrary.org/search?q=To%20Kill%20a%20Mockingbird%20Harper%20Lee','sedang',2,'B3',2,2,2),
('B129','The Great Gatsby','F. Scott Fitzgerald',(SELECT id FROM kategori WHERE nama='Fiksi klasik'),1925,'Charles Scribner''s Sons','9780743273565',NULL,'Novel tentang Jay Gatsby, cinta, kekayaan, dan impian Amerika pada era 1920-an.',10590366,NULL,'https://openlibrary.org/search?q=The%20Great%20Gatsby%20F.%20Scott%20Fitzgerald','sedang',2,'B3',2,2,2),
('B130','The Hobbit','J. R. R. Tolkien',(SELECT id FROM kategori WHERE nama='Fantasi'),1937,'Houghton Mifflin Harcourt','9780547928227',NULL,'Bilbo Baggins meninggalkan kehidupan nyaman untuk bergabung dalam petualangan menuju Lonely Mountain.',14627509,NULL,'https://openlibrary.org/search?q=The%20Hobbit%20J.%20R.%20R.%20Tolkien','sedang',2,'B3',2,2,2),
('B131','Harry Potter and the Philosopher''s Stone','J. K. Rowling',(SELECT id FROM kategori WHERE nama='Fantasi'),1997,'Bloomsbury','9780590353427',NULL,'Harry Potter mengetahui asal-usul sihirnya dan memulai tahun pertama di Hogwarts School of Witchcraft and Wizardry.',15155833,NULL,'https://openlibrary.org/search?q=Harry%20Potter%20and%20the%20Philosopher''s%20Stone%20J.%20K.%20Rowling','sedang',2,'B3',2,2,2),
('B132','The Little Prince','Antoine de Saint-Exupéry',(SELECT id FROM kategori WHERE nama='Fabel'),1943,'Harcourt','9780156012195',NULL,'Seorang pilot yang terdampar di gurun bertemu pangeran kecil dan mendengar kisah perjalanannya mengunjungi berbagai planet.',10708272,NULL,'https://openlibrary.org/search?q=The%20Little%20Prince%20Antoine%20de%20Saint-Exup%C3%83%C2%A9ry','sedang',2,'B3',2,2,2),
('B133','Animal Farm','George Orwell',(SELECT id FROM kategori WHERE nama='Fiksi satir'),1945,'Secker & Warburg',NULL,NULL,'Satire politik tentang sekelompok hewan yang mengambil alih peternakan dan membangun tatanan baru.',11261770,NULL,'https://openlibrary.org/search?q=Animal%20Farm%20George%20Orwell','sedang',2,'B3',2,2,2),
('B134','The Alchemist','Paulo Coelho',(SELECT id FROM kategori WHERE nama='Fiksi'),1988,'HarperOne','9780061122415',NULL,'Santiago, seorang gembala muda, melakukan perjalanan untuk mencari harta karun dan memahami panggilan hidupnya.',7414780,NULL,'https://openlibrary.org/search?q=The%20Alchemist%20Paulo%20Coelho','sedang',2,'B3',2,2,2),
('B135','Fahrenheit 451','Ray Bradbury',(SELECT id FROM kategori WHERE nama='Fiksi distopia'),1953,'Simon & Schuster','9781451673319',NULL,'Guy Montag bekerja sebagai petugas pembakar buku dalam masyarakat yang melarang membaca dan berpikir kritis.',12993656,NULL,'https://openlibrary.org/search?q=Fahrenheit%20451%20Ray%20Bradbury','sedang',2,'B3',2,2,2),
('B136','Pride and Prejudice','Jane Austen',(SELECT id FROM kategori WHERE nama='Fiksi klasik'),1813,'Penguin Classics','9780141439518',NULL,'Elizabeth Bennet dan Mr. Darcy menghadapi prasangka, kesalahpahaman, dan aturan sosial Inggris pada zamannya.',14348537,NULL,'https://openlibrary.org/search?q=Pride%20and%20Prejudice%20Jane%20Austen','sedang',2,'B3',2,2,2),
('B137','The Book Thief','Markus Zusak',(SELECT id FROM kategori WHERE nama='Fiksi sejarah'),2005,'Picador','9780375842207',NULL,'Liesel Meminger menemukan kekuatan kata-kata saat hidup di Jerman pada masa Perang Dunia II.',15267110,NULL,'https://openlibrary.org/search?q=The%20Book%20Thief%20Markus%20Zusak','sedang',2,'B3',2,2,2),
('B138','Educated','Tara Westover',(SELECT id FROM kategori WHERE nama='Memoar'),2018,'Random House','9780399590504',NULL,'Memoar Tara Westover tentang masa kecil tanpa sekolah formal dan perjalanannya memperoleh pendidikan.',8314077,NULL,'https://openlibrary.org/search?q=Educated%20Tara%20Westover','sedang',2,'B3',2,2,2),
('B139','Becoming','Michelle Obama',(SELECT id FROM kategori WHERE nama='Memoar'),2018,'Crown Publishing Group','9781524763138',NULL,'Memoar Michelle Obama tentang masa kecil, karier, keluarga, dan pengalamannya di Gedung Putih.',8824664,NULL,'https://openlibrary.org/search?q=Becoming%20Michelle%20Obama','sedang',2,'B3',2,2,2),
('B140','Man''s Search for Meaning','Viktor E. Frankl',(SELECT id FROM kategori WHERE nama='Psikologi'),1946,'Beacon Press','9780807014295',NULL,'Memoar dan refleksi psikiater Viktor Frankl tentang pencarian makna dalam penderitaan dan pengalaman kamp konsentrasi.',8516506,NULL,'https://openlibrary.org/search?q=Man''s%20Search%20for%20Meaning%20Viktor%20E.%20Frankl','sedang',2,'B3',2,2,2),
('B141','The Catcher in the Rye','J. D. Salinger',(SELECT id FROM kategori WHERE nama='Fiksi'),1951,'Little, Brown and Company','9780316769488',NULL,'Holden Caulfield menceritakan beberapa hari dalam hidupnya setelah meninggalkan sekolah di New York.',9273490,NULL,'https://openlibrary.org/search?q=The%20Catcher%20in%20the%20Rye%20J.%20D.%20Salinger','sedang',2,'B3',2,2,2),
('B142','The Kite Runner','Khaled Hosseini',(SELECT id FROM kategori WHERE nama='Fiksi sejarah'),2003,'Riverhead Books','9781594631931',NULL,'Persahabatan Amir dan Hassan terbentang dari masa kecil di Kabul hingga kehidupan mereka di tempat lain.',14846827,NULL,'https://openlibrary.org/search?q=The%20Kite%20Runner%20Khaled%20Hosseini','sedang',2,'B3',2,2,2),
('B143','The Hunger Games','Suzanne Collins',(SELECT id FROM kategori WHERE nama='Fiksi distopia'),2008,'Scholastic Press','9780439023528',NULL,'Katniss Everdeen menjadi peserta Hunger Games, kompetisi televisi yang mempertaruhkan nyawa para remaja.',12646537,NULL,'https://openlibrary.org/search?q=The%20Hunger%20Games%20Suzanne%20Collins','sedang',2,'B3',2,2,2),
('B144','Dune','Frank Herbert',(SELECT id FROM kategori WHERE nama='Fiksi ilmiah'),1965,'Ace Books','9780441172719',NULL,'Paul Atreides tiba di Arrakis, planet gurun yang menjadi pusat perebutan sumber daya dan kekuasaan antarkeluarga.',11481354,NULL,'https://openlibrary.org/search?q=Dune%20Frank%20Herbert','sedang',2,'B3',2,2,2),
('B145','Frankenstein','Mary Shelley',(SELECT id FROM kategori WHERE nama='Fiksi gotik'),1818,'Dover Publications','9780486282114',NULL,'Victor Frankenstein menciptakan makhluk hidup dalam eksperimen ilmiah yang membawa konsekuensi tragis.',12356249,NULL,'https://openlibrary.org/search?q=Frankenstein%20Mary%20Shelley','sedang',2,'B3',2,2,2),
('B146','Jane Eyre','Charlotte Brontë',(SELECT id FROM kategori WHERE nama='Fiksi klasik'),1847,'Penguin Classics','9780141441146',NULL,'Jane Eyre tumbuh dari masa kecil yang sulit menuju kemandirian dan menghadapi rahasia di Thornfield Hall.',8235363,NULL,'https://openlibrary.org/search?q=Jane%20Eyre%20Charlotte%20Bront%C3%83%C2%AB','sedang',2,'B3',2,2,2),
('B147','The Da Vinci Code','Dan Brown',(SELECT id FROM kategori WHERE nama='Thriller'),2003,'Anchor Books','9780307474278',NULL,'Robert Langdon dan Sophie Neveu mengikuti petunjuk simbolis dalam penyelidikan misteri di Paris.',9255229,NULL,'https://openlibrary.org/search?q=The%20Da%20Vinci%20Code%20Dan%20Brown','sedang',2,'B3',2,2,2),
('B148','A Thousand Splendid Suns','Khaled Hosseini',(SELECT id FROM kategori WHERE nama='Fiksi sejarah'),2007,'Riverhead Books','9781594483073',NULL,'Kisah dua perempuan Afghanistan, Mariam dan Laila, yang hidupnya bertaut di tengah konflik dan perubahan politik.',8579790,NULL,'https://openlibrary.org/search?q=A%20Thousand%20Splendid%20Suns%20Khaled%20Hosseini','sedang',2,'B3',2,2,2),
('B149','A Brief History of Time','Stephen Hawking',(SELECT id FROM kategori WHERE nama='Sains'),1988,'Bantam Books','9780553380163',NULL,'Pengantar populer Stephen Hawking tentang kosmologi, ruang-waktu, lubang hitam, dan asal-usul alam semesta.',10432365,NULL,'https://openlibrary.org/search?q=A%20Brief%20History%20of%20Time%20Stephen%20Hawking','sedang',2,'B3',2,2,2),
('B150','Cosmos','Carl Sagan',(SELECT id FROM kategori WHERE nama='Sains'),1980,'Ballantine Books','9780345539434',NULL,'Carl Sagan membawa pembaca menjelajahi sejarah alam semesta, perkembangan ilmu pengetahuan, dan posisi manusia di dalamnya.',8283901,NULL,'https://openlibrary.org/search?q=Cosmos%20Carl%20Sagan','sedang',2,'B3',2,2,2),
('B151','Silent Spring','Rachel Carson',(SELECT id FROM kategori WHERE nama='Lingkungan'),1962,'Mariner Books','9780618249060',NULL,'Karya Rachel Carson tentang dampak pestisida terhadap lingkungan dan kesadaran publik mengenai ekologi.',3825693,NULL,'https://openlibrary.org/search?q=Silent%20Spring%20Rachel%20Carson','sedang',2,'B3',2,2,2),
('B152','The Immortal Life of Henrietta Lacks','Rebecca Skloot',(SELECT id FROM kategori WHERE nama='Sains & biografi'),2010,'Crown Publishers','9781400052189',NULL,'Kisah Henrietta Lacks dan sel HeLa, serta pertanyaan tentang keluarga, penelitian medis, persetujuan, dan etika.',8364866,NULL,'https://openlibrary.org/search?q=The%20Immortal%20Life%20of%20Henrietta%20Lacks%20Rebecca%20Skloot','sedang',2,'B3',2,2,2);

-- Ruang
INSERT INTO ruang (kode, nama, kapasitas, detail) VALUES
('ruang-senja',  'Ruang Senja',  6,  'Ruang diskusi dengan papan tulis.'),
('studio-kata',  'Studio Kata',  4,  'Studio rekaman dan kegiatan kreatif.'),
('meja-komunal', 'Meja Komunal', 10, 'Area belajar kolaboratif.');

-- Acara (tanggal relatif terhadap hari seed dijalankan)
INSERT INTO acara (judul, tipe, tanggal, jam, lokasi, kuota, deskripsi) VALUES
('Bedah Buku: Laut Bercerita',          'bedah buku', CURDATE() + INTERVAL 3 DAY, '15:00', 'Ruang Senja',  20, 'Berbagi perspektif tentang ingatan, persahabatan, dan sejarah.'),
('Workshop: Merawat Kebiasaan Membaca', 'workshop',   CURDATE() + INTERVAL 5 DAY, '10:00', 'Studio Kata',   16, 'Latihan praktis membangun rutinitas membaca yang nyaman.'),
('Klub Baca Cerita Indonesia',          'klub baca',  CURDATE() + INTERVAL 6 DAY, '13:00', 'Meja Komunal',  18, 'Bertemu dan berdiskusi tentang cerita dari berbagai daerah.');
