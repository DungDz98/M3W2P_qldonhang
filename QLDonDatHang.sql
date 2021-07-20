create table Customer(
	IdKH int not null primary key,
    HoTen nvarchar(100),
    DiaChi nvarchar(50)
);

create table Product(
	IdSP int not null primary key,
    TenSP nvarchar(100),
    Gia int,
    MadeIn nvarchar(50)
);

create table Orders(
	IdHD int not null primary key,
    Ngay date,
    TongGia int,
    IdKH int not null,
    foreign key (IDKH) references Customer(IdKH)
);

alter table Orders
modify TongGia double;

create table OrderDetail(
	IdHDCT int not null primary key,
    SoLuong int,
    IdSP int not null,
    IdHD int not null,
    foreign key (IdSP) references Product(IdSP),
    foreign key (IdHD) references Orders(IdHD)
);


-- Orders chi tiết có giá
create view FullOrders as
select Orders.IDHD, Ngay, sum(SoLuong * Gia) as TotalPrice, IDKH
from (Orders, Product) join OrderDetail
on (OrderDetail.IDSP = Product.IDSP) and (OrderDetail.IDHD = Orders.IDHD)
group by IdHD
order by IDHD;

select * from FullOrders;

drop view FullOrders;

-- 6. In ra số hóa đơn, trị giá hóa đơn bán trong ngày 19/6/2007 và 20/6/2007
select IDHD, Ngay, TotalPrice
from FullOrders
where Ngay in ('2006-06-19', '2006-06-20');

-- 7. In ra số hóa đơn, trị giá hóa đơn trong tháng 6/2007, sắp xếp theo ngày tăng dần, trị giá giảm dần
select IDHD, Ngay, TotalPrice
from FullOrders
where month(Ngay) = 6 and year(Ngay) = 2007
order by Ngay, TotalPrice desc;

-- 8. In ra MaKH, HoTen
select c.IDKH, c.HoTen
from Customer c, Orders o
where C.IdKH = O.IdKH and Ngay = '2007-06-19';

-- 10. In ra MaSP, TenSP được khách hàng Nguyễn A trong tháng 10/2006
select *
from (Product p, Orders o, Customer c) join OrderDetail od
on (p.IDSP = od.IDSP) and (o.IDHD = od.IDHD) and (o.IdKH = c.IDKH)
where month(Ngay) = 10 and year(Ngay) = 2006 and HoTen like 'Nguyễn%';

-- 11. Số hóa đơn đã mua 'Máy giặt' hoặc 'Tủ lạnh'
select o.IdHD, p.TenSP
from (Product p, Orders o) join OrderDetail od
on p.IDSP = od.IDSP and o.IDHD = od.IDHD
where TenSP in ('Máy Giặt', 'Tủ lạnh');

-- 12. Số hóa đơn đã mua 'Máy giặt' hoặc 'Tủ lạnh', số lượng mỗi sp 4-7
select o.IdHD, p.TenSP, od.SoLuong
from (Product p, Orders o) join OrderDetail od
on p.IDSP = od.IDSP and o.IDHD = od.IDHD
where TenSP in ('Máy Giặt', 'Tủ lạnh') and SoLuong between 4 and 7;

-- 13. Số hóa đơn mua cùng lúc 2 sản phẩm 'Máy Giặt' và 'Tủ lạnh', số lượng mua sp 4-7
select IdHD from OrderDetail od
join Product p on od.idSP = p.idSP
where tenSP in ('Máy Giặt', 'Tủ lạnh') and SoLuong between 4 and 7
group by idHD
having count(idHD)=2;

-- 15. In ra MaSP, TenSP không bán được
select idSP, tenSP from Product
where not idSP in (select idSP from OrderDetail);

-- 16. In ra MaSP, TenSP không bán được trong năm 2006
select p.idSP, p.tenSP from Product p
where not idSP in (
select p.idSP
from (Product p, Orders o) join OrderDetail od
on p.IDSP = od.IDSP and o.IDHD = od.IDHD
where year(Ngay) = 2006
);

-- 17. In ra MaSP, TenSP giá > 300 bán được trong năm 2006
select p.idSP, p.tenSP from Product p
where idSP in (
select p.idSP
from (Product p, Orders o) join OrderDetail od
on p.IDSP = od.IDSP and o.IDHD = od.IDHD
where year(Ngay) = 2006 and Gia > 300
);




