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
  {$I-} reset(fileBuku); {$I+}

  if IOResult <> 0 then
  begin
    jumlah := 0;
    exit;
  end;

  jumlah := filesize(fileBuku);
  for i := 1 to jumlah do
    read(fileBuku, buku[i]);

  close(fileBuku);
end;

procedure SaveData;
var
  i : integer;
begin
  assign(fileBuku, FILE_NAME);
  rewrite(fileBuku);

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

  if jumlah + tambah > MAX then
  begin
    writeln('Kapasitas buku penuh!');
    readln;
    exit;
  end;

  for i := jumlah + 1 to jumlah + tambah do
  begin
    writeln('Data Buku ke-', i);
    write('Kode Buku   : '); readln(buku[i].kode);
    write('Judul Buku  : '); readln(buku[i].judul);
    write('Penulis     : '); readln(buku[i].penulis);
    write('Stok        : '); readln(buku[i].stok);

    buku[i].peminjam := '-';
    buku[i].kembali  := '-';
  end;

  jumlah := jumlah + tambah;
  SaveData;
end;

procedure TampilBuku;
var
  i : integer;
begin
  clrscr;
  writeln('DAFTAR BUKU PERPUSTAKAAN');
  writeln('========================');

  if jumlah = 0 then
    writeln('Belum ada data buku')
  else
  begin
    for i := 1 to jumlah do
    begin
      writeln('Kode    : ', buku[i].kode);
      writeln('Judul   : ', buku[i].judul);
      writeln('Penulis : ', buku[i].penulis);
      writeln('Stok    : ', buku[i].stok);

      if buku[i].stok > 0 then
        writeln('Status  : Tersedia')
      else
      begin
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
  CariBuku := 0;
  for i := 1 to jumlah do
    if buku[i].kode = kodeCari then
    begin
      CariBuku := i;
      exit;
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

  idx := CariBuku(kodeCari);

  if idx = 0 then
    writeln('Buku tidak ditemukan')
  else if buku[idx].stok > 0 then
  begin
    write('Nama Peminjam       : ');
    readln(buku[idx].peminjam);
    write('Jadwal Pengembalian : ');
    readln(buku[idx].kembali);

    buku[idx].stok := buku[idx].stok - 1;
    SaveData;
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

  idx := CariBuku(kodeCari);

  if idx = 0 then
    writeln('Buku tidak ditemukan')
  else
  begin
    buku[idx].stok := buku[idx].stok + 1;
    buku[idx].peminjam := '-';
    buku[idx].kembali  := '-';
    SaveData;
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

  case pilih of
    1 : TambahBuku;
    2 : TampilBuku;
    3 : PinjamBuku;
    4 : KembalikanBuku;
    5 : begin
          SaveData;
          writeln('Data disimpan. Terima kasih');
        end;
  else
    writeln('Pilihan tidak valid');
  end;
end;

{================ PROGRAM UTAMA ================}
begin
  LoadData;
  repeat
    Menu;
  until pilih = 5;
end.