program LibraryManagement;

uses crt;

const
  MAX = 100;
  FILE_NAME = 'buku.dat';

type
  TBuku = record
    kode    : string[10];
    judul   : string[30];
    penulis : string[30];
    stok    : integer;
    peminjam: string[30];
    kembali : string[15];
  end;

var
  buku     : array[1..MAX] of TBuku;
  jumlah   : integer;
  pilih    : integer;
  fileBuku : file of TBuku;

{================ FILE HANDLING ================}
procedure LoadData;
var
  i : integer;
begin
  assign(fileBuku, FILE_NAME);
  {$I-} reset(fileBuku); {$I+}  {Matikan error checking sementara}

  {Cek apakah file berhasil dibuka}
  if IOResult <> 0 then  
  begin
    jumlah := 0;  {Jika file belum ada, set jumlah = 0}
    exit;
  end;

  {Hitung jumlah record dalam file}
  jumlah := filesize(fileBuku);
  
  {Baca semua data dari file ke array}
  for i := 1 to jumlah do
    read(fileBuku, buku[i]);

  close(fileBuku);
end;

procedure SaveData;
var
  i : integer;
begin
  assign(fileBuku, FILE_NAME);
  rewrite(fileBuku);  {Buat file baru atau overwrite}

  {Simpan semua data dari array ke file}
  for i := 1 to jumlah do
    write(fileBuku, buku[i]);

  close(fileBuku);
end;

{================ PROCEDURE & FUNCTION ================}
procedure TambahBuku;
var
  i, tambah : integer;
begin
  clrscr;
  write('Masukkan jumlah buku yang ingin ditambahkan: ');
  readln(tambah);

  {Cek apakah masih ada kapasitas}
  if jumlah + tambah > MAX then
  begin
    writeln('Kapasitas buku penuh!');
    readln;
    exit;
  end;

  {Input data buku mulai dari index setelah data terakhir}
  for i := jumlah + 1 to jumlah + tambah do
  begin
    writeln('Data Buku ke-', i);
    write('Kode Buku   : '); readln(buku[i].kode);
    write('Judul Buku  : '); readln(buku[i].judul);
    write('Penulis     : '); readln(buku[i].penulis);
    write('Stok        : '); readln(buku[i].stok);

    {Set default value untuk buku baru}
    buku[i].peminjam := '-';
    buku[i].kembali  := '-';
  end;

  {Update jumlah total buku}
  jumlah := jumlah + tambah;
  SaveData;  {Simpan perubahan ke file}
end;

procedure TampilBuku;
var
  i : integer;
begin
  clrscr;
  writeln('DAFTAR BUKU PERPUSTAKAAN');
  writeln('========================');

  {Validasi apakah ada data}
  if jumlah = 0 then
    writeln('Belum ada data buku')
  else
  begin
    {Loop untuk menampilkan semua buku}
    for i := 1 to jumlah do
    begin
      writeln('Kode    : ', buku[i].kode);
      writeln('Judul   : ', buku[i].judul);
      writeln('Penulis : ', buku[i].penulis);
      writeln('Stok    : ', buku[i].stok);

      {Tampilkan status berdasarkan stok}
      if buku[i].stok > 0 then
        writeln('Status  : Tersedia')
      else
      begin
        {Jika stok 0, tampilkan info peminjam}
        writeln('Status  : Dipinjam');
        writeln('Peminjam       : ', buku[i].peminjam);
        writeln('Jadwal Kembali : ', buku[i].kembali);
      end;

      writeln('------------------------');
    end;
  end;
  readln;
end;

function CariBuku(kodeCari : string): integer;
var
  i : integer;
begin
  CariBuku := 0;  {Default return 0 jika tidak ditemukan}
  
  {Loop mencari buku berdasarkan kode}
  for i := 1 to jumlah do
    if buku[i].kode = kodeCari then
    begin
      CariBuku := i;  {Return index array jika ditemukan}
      exit;  {Keluar dari function segera setelah ketemu}
    end;
end;

procedure PinjamBuku;
var
  kodeCari : string;
  idx : integer;
begin
  clrscr;
  write('Masukkan kode buku yang ingin dipinjam: ');
  readln(kodeCari);

  {Cari buku berdasarkan kode}
  idx := CariBuku(kodeCari);

  {Validasi hasil pencarian}
  if idx = 0 then
    writeln('Buku tidak ditemukan')
  else if buku[idx].stok > 0 then
  begin
    {Input data peminjam}
    write('Nama Peminjam       : ');
    readln(buku[idx].peminjam);
    write('Jadwal Pengembalian : ');
    readln(buku[idx].kembali);

    {Kurangi stok buku}
    buku[idx].stok := buku[idx].stok - 1;
    SaveData;  {Simpan perubahan ke file}
    writeln('Buku berhasil dipinjam');
  end
  else
    writeln('Stok buku habis');

  readln;
end;

procedure KembalikanBuku;
var
  kodeCari : string;
  idx : integer;
begin
  clrscr;
  write('Masukkan kode buku yang ingin dikembalikan: ');
  readln(kodeCari);

  {Cari buku berdasarkan kode}
  idx := CariBuku(kodeCari);

  {Validasi hasil pencarian}
  if idx = 0 then
    writeln('Buku tidak ditemukan')
  else
  begin
    {Tambah stok dan reset data peminjam}
    buku[idx].stok := buku[idx].stok + 1;
    buku[idx].peminjam := '-';  {Hapus nama peminjam}
    buku[idx].kembali  := '-';  {Hapus jadwal kembali}
    SaveData;  {Simpan perubahan ke file}
    writeln('Buku berhasil dikembalikan');
  end;

  readln;
end;

procedure Menu;
begin
  clrscr;
  writeln('MENU LIBRARY MANAGEMENT');
  writeln('1. Tambah Buku');
  writeln('2. Tampilkan Buku');
  writeln('3. Pinjam Buku');
  writeln('4. Kembalikan Buku');
  writeln('5. Keluar');
  write('Pilih menu [1-5]: ');
  readln(pilih);

  {Panggil procedure sesuai pilihan}
  case pilih of
    1 : TambahBuku;
    2 : TampilBuku;
    3 : PinjamBuku;
    4 : KembalikanBuku;
    5 : begin
          SaveData;  {Pastikan data tersimpan sebelum keluar}
          writeln('Data disimpan. Terima kasih');
        end;
  else
    writeln('Pilihan tidak valid');
  end;
end;

{================ PROGRAM UTAMA ================}
begin
  LoadData;  {Load data dari file saat program dimulai}
  repeat
    Menu;  {Tampilkan menu berulang}
  until pilih = 5;  {Loop sampai user pilih keluar}
end.
