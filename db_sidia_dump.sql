-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 172.17.0.3
-- Generation Time: Jul 22, 2023 at 02:27 AM
-- Server version: 8.0.23
-- PHP Version: 8.1.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_sidia`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`%` PROCEDURE `klasifikasi_produk` ()   BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE total DECIMAL(10,2);
	DECLARE kategori VARCHAR(20);

    -- Mendeklarasikan cursor untuk mengambil data dari tabel "produk"
    DECLARE cur CURSOR FOR
        SELECT (harga * jumlah) as total FROM detail_transaksi;
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Proses pembacaan data dari cursor dan kontrol aliran
    OPEN cur;
    read_loop: LOOP
        -- Mengambil baris berikutnya dari cursor ke variabel yang telah dideklarasikan
        FETCH cur INTO total;

        -- Memeriksa apakah data telah selesai dibaca dari cursor
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Klasifikasi produk berdasarkan harga
        CASE
            WHEN total < 10000 THEN
                SET kategori = 'Sedikit';
            WHEN total >= 10000 AND total <= 100000 THEN
                SET kategori = 'Menengah';
            ELSE
                SET kategori = 'Banyak';
        END CASE;

        -- Tampilkan hasil klasifikasi pada console
        SELECT CONCAT('Total: ', total, ', Kategori: ', kategori) AS result;
    END LOOP;

    -- Menutup cursor setelah selesai digunakan
    CLOSE cur;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`%` FUNCTION `tambahsupplier` (`paramnama` VARCHAR(100), `paramalamat` TEXT, `paramno_hp` VARCHAR(15)) RETURNS INT  BEGIN
 DECLARE new_id INT;
 INSERT INTO supplier (nama, alamat, no_hp)
 SELECT paramnama, paramalamat, paramno_hp;
 SET new_id = LAST_INSERT_ID();
 RETURN new_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `id` int NOT NULL,
  `nama` varchar(100) NOT NULL,
  `satuan` varchar(20) DEFAULT NULL,
  `stok` int DEFAULT '0',
  `id_kategori` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`id`, `nama`, `satuan`, `stok`, `id_kategori`) VALUES
(1, 'Laptop', 'unit', 15, 1),
(2, 'Kemeja', 'buah', 30, 2),
(3, 'Kacang', 'gram', 1000, 3),
(4, 'Air Mineral', 'botol', 500, 4),
(5, 'Piring', 'buah', 50, 5),
(6, 'Bola Sepak', 'buah', 25, 6),
(7, 'Lipstik', 'buah', 40, 7),
(8, 'Boneka', 'buah', 20, 8),
(9, 'Buku Novel', 'buah', 15, 9),
(10, 'Cincin', 'buah', 5, 10);

-- --------------------------------------------------------

--
-- Table structure for table `detail_transaksi`
--

CREATE TABLE `detail_transaksi` (
  `id` int NOT NULL,
  `id_transaksi` int DEFAULT NULL,
  `id_barang` int DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `jumlah` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `detail_transaksi`
--

INSERT INTO `detail_transaksi` (`id`, `id_transaksi`, `id_barang`, `harga`, `jumlah`) VALUES
(1, 1, 1, 15000000.00, 5),
(2, 1, 2, 200000.00, 10),
(3, 2, 3, 50000.00, 20),
(4, 2, 4, 10000.00, 100),
(5, 3, 5, 25000.00, 10),
(6, 3, 6, 70000.00, 5),
(7, 4, 7, 120000.00, 4),
(8, 4, 8, 80000.00, 3),
(9, 5, 9, 75000.00, 2),
(10, 5, 10, 500000.00, 10),
(11, 5, 10, 500000.00, 5);

--
-- Triggers `detail_transaksi`
--
DELIMITER $$
CREATE TRIGGER `tg_penambahan_stok_after_insert` AFTER INSERT ON `detail_transaksi` FOR EACH ROW BEGIN
	DECLARE in_jenis enum('pembelian','pembayaran');
    
    SELECT jenis INTO in_jenis
    FROM transaksi WHERE id = NEW.id_transaksi; 
    
	IF in_jenis = "pembelian" THEN
		UPDATE barang SET stok = stok + NEW.jumlah WHERE id = NEW.id_barang;
	ELSEIF in_jenis = "pembayaran" THEN
    	UPDATE barang SET stok = stok - NEW.jumlah WHERE id = NEW.id_barang;
    END IF;
    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tg_penambahan_stok_after_update` AFTER UPDATE ON `detail_transaksi` FOR EACH ROW BEGIN
	DECLARE in_jenis enum('pembelian','pembayaran');
    
    SELECT jenis INTO in_jenis
    FROM transaksi WHERE id = NEW.id_transaksi; 
    
	IF in_jenis = "pembelian" THEN
		UPDATE barang SET stok = stok - OLD.jumlah + NEW.jumlah WHERE id = NEW.id_barang;
	ELSEIF in_jenis = "pembayaran" THEN
    	UPDATE barang SET stok = stok + OLD.jumlah - NEW.jumlah WHERE id = NEW.id_barang;
    END IF;
    
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kategori`
--

CREATE TABLE `kategori` (
  `id` int NOT NULL,
  `nama` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kategori`
--

INSERT INTO `kategori` (`id`, `nama`) VALUES
(1, 'Elektronik'),
(2, 'Fashion'),
(3, 'Makanan'),
(4, 'Minuman'),
(5, 'Peralatan Rumah Tangga'),
(6, 'Olahraga'),
(7, 'Kecantikan'),
(8, 'Mainan'),
(9, 'Buku'),
(10, 'Perhiasan');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int NOT NULL,
  `barang_id` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `star` int DEFAULT NULL,
  `user_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `id` int NOT NULL,
  `nama` varchar(100) NOT NULL,
  `alamat` text,
  `no_hp` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`id`, `nama`, `alamat`, `no_hp`) VALUES
(1, 'PT. Abadi Jaya', 'Jl. Raya No. 1, Jakarta', '08111111111'),
(2, 'CV. Berkat Sukses', 'Jl. Kebayoran No. 2, Surabaya', '08222222222'),
(3, 'UD. Cahaya Makmur', 'Jl. Merdeka No. 3, Bandung', '08333333333'),
(4, 'PT. Makmur Jaya', 'Jl. Sudirman No. 4, Medan', '08444444444'),
(5, 'CV. Sinar Baru', 'Jl. Gatot Subroto No. 5, Makassar', '08555555555'),
(6, 'UD. Sejahtera', 'Jl. Asia Afrika No. 6, Yogyakarta', '08666666666'),
(7, 'PT. Bintang Jasa', 'Jl. Diponegoro No. 7, Semarang', '08777777777'),
(8, 'CV. Mandiri Teknik', 'Jl. Panglima Polim No. 8, Bandar Lampung', '08888888888'),
(9, 'UD. Berkah Sentosa', 'Jl. Hayam Wuruk No. 9, Palembang', '08999999999'),
(10, 'PT. Cemerlang Indah', 'Jl. Pahlawan No. 10, Denpasar', '08000000000');

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `id` int NOT NULL,
  `tanggal` date DEFAULT NULL,
  `jenis` enum('pembelian','pembayaran') NOT NULL,
  `id_user` int DEFAULT NULL,
  `id_supplier` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`id`, `tanggal`, `jenis`, `id_user`, `id_supplier`) VALUES
(1, '2023-07-15', 'pembelian', 1, 1),
(2, '2023-07-16', 'pembelian', 2, 2),
(3, '2023-07-17', 'pembelian', 3, 3),
(4, '2023-07-18', 'pembayaran', 4, 4),
(5, '2023-07-19', 'pembayaran', 5, 5),
(6, '2023-07-20', 'pembayaran', 1, 6),
(7, '2023-07-21', 'pembelian', 2, 7),
(8, '2023-07-22', 'pembayaran', 3, 8),
(9, '2023-07-23', 'pembelian', 4, 9),
(10, '2023-07-24', 'pembayaran', 5, 10);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int NOT NULL,
  `nama` varchar(50) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `no_hp` varchar(15) NOT NULL,
  `tipe` enum('admin','operator') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `nama`, `username`, `password`, `no_hp`, `tipe`) VALUES
(1, 'Budi Santoso', 'budi123', 'budi123pass', '081234567891', 'admin'),
(2, 'Ani Kusuma', 'ani456', 'ani456pass', '081234567892', 'admin'),
(3, 'Tono Wijaya', 'tono789', 'tono789pass', '081234567893', 'operator'),
(4, 'Rina Indriani', 'rina001', 'rina001pass', '081234567894', 'operator'),
(5, 'Sinta Mulyani', 'sinta002', 'sinta002pass', '081234567895', 'operator'),
(6, 'Fajar Pratama', 'fajar003', 'fajar003pass', '081234567896', 'admin'),
(7, 'Dita Sari', 'dita004', 'dita004pass', '081234567897', 'operator'),
(8, 'Rizky Wibowo', 'rizky005', 'rizky005pass', '081234567898', 'admin'),
(9, 'Dewi Amelia', 'dewi006', 'dewi006pass', '081234567899', 'operator'),
(10, 'Andi Kurniawan', 'andi007', 'andi007pass', '081234567890', 'admin');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_invoice`
-- (See below for the actual view)
--
CREATE TABLE `v_invoice` (
`harga` decimal(10,2)
,`id` int
,`jumlah` int
,`nama` varchar(100)
,`stok` int
,`tanggal` date
,`total_harga` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Structure for view `v_invoice`
--
DROP TABLE IF EXISTS `v_invoice`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `v_invoice`  AS SELECT `transaksi`.`id` AS `id`, `barang`.`nama` AS `nama`, `barang`.`stok` AS `stok`, `detail_transaksi`.`harga` AS `harga`, `detail_transaksi`.`jumlah` AS `jumlah`, (`detail_transaksi`.`jumlah` * `detail_transaksi`.`harga`) AS `total_harga`, `transaksi`.`tanggal` AS `tanggal` FROM ((`detail_transaksi` join `barang` on((`barang`.`id` = `detail_transaksi`.`id`))) join `transaksi` on((`transaksi`.`id` = `detail_transaksi`.`id_transaksi`))) ORDER BY `transaksi`.`tanggal` ASC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_kategori` (`id_kategori`);

--
-- Indexes for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_transaksi` (`id_transaksi`),
  ADD KEY `id_barang` (`id_barang`);

--
-- Indexes for table `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `barang_id` (`barang_id`),
  ADD KEY `idx_star` (`star`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_supplier` (`id_supplier`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `barang`
--
ALTER TABLE `barang`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `barang`
--
ALTER TABLE `barang`
  ADD CONSTRAINT `barang_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id`);

--
-- Constraints for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD CONSTRAINT `detail_transaksi_ibfk_1` FOREIGN KEY (`id_transaksi`) REFERENCES `transaksi` (`id`),
  ADD CONSTRAINT `detail_transaksi_ibfk_2` FOREIGN KEY (`id_barang`) REFERENCES `barang` (`id`);

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `transaksi_ibfk_2` FOREIGN KEY (`id_supplier`) REFERENCES `supplier` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
