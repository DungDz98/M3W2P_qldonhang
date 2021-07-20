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

-- 18. Tìm số hóa đơn đã mua tất cả các sản phẩm > 200
select * from (Product p, Orders o)
join OrderDetail od
on p.IdSP = od.IDSP and o.IDHD = od.IDHD
where not o.idHD in (
select o.idHD from (Product p, Orders o)
join OrderDetail od
on p.IdSP = od.IDSP and o.IDHD = od.IDHD
where Gia <= 200);

-- 19. Số hóa đơn trong 2006 có tất cả sản phẩm có giá < 300

-- 21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006

-- 22. Trị giá hóa đơn max, min
select min(TongGia) as min, max(TongGia) as max from Orders;
-- 23. Trị giá hóa đơn trung bình năm 2006
select avg(TongGia) as TB from Orders o
inner join Orderdetail od on od.idHD = o.idHD
where year(ngay) = 2006 and  SoLuong > 0;
-- 24. Doanh thu bán hàng năm 2006
select sum(tonggia) as doanhthu from Orders
where year(ngay) = 2006;
-- 25. Số hóa đơn có trị giá cao nhất 2006
select o.idHD, tongGia from Orders o
where year(ngay) = 2006 and TongGia = (select max(tonggia) from Orders);

-- 26. Họ tên khách hàng đã mua hóa đơn có trị giá cao nhất 2006

-- 27. In ra MaKH, HoTen mua nhiều hàng nhất(số lượng)
select c.IdKH, HoTen, sum(soluong) as 'Số lượng sản phẩm' from (Customer c, Orders o)
join OrderDetail od
on c.IdKH = o.IDKH and o.IDHD = od.IDHD
group by c.IdKH
order by sum(soluong) desc
limit 3;

-- 28. In ra MaSP, TenSP có giá bán bằng 1 trong 3 mức giá cao nhất
select IdSP, TenSP from Product
where Gia in (select * from (select distinct Gia from Product order by Gia desc limit 3) as Top3GiaCao);

-- 29. In ra MaSP, TenSP có tên bắt đầu bằng M, giá bằng 1 trong 3 mức giá cao nhất
select IdSP, TenSP from Product
where Gia in (select * from (select distinct Gia from Product order by Gia desc limit 3) as Top3GiaCao)
and TenSP like 'M%';

-- 32. Tính tổng số sản phẩm giá < 300
select count(*) as 'Tổng sp < 300' from Product
where gia < 300;

-- 33. Tính tổng số sản phẩm theo từng giá
select gia, count(*) as 'Số sản phẩm' from Product
group by gia;

-- 34. Tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm bắt đầu bằng chữ M
select max(gia) as 'Giá max', min(gia) as 'Giá min', format(avg(gia), 0) as 'Giá TB' from product
where tenSP like 'M%';

-- 35. Tính doanh thu bán hàng mỗi ngày
select ngay, sum(TongGia) from Orders
group by ngay;

-- 36. Tính tổng số lượng của từng sản phẩm trong 10/2006
select TenSP, sum(SoLuong) as 'Số lượng' from (Orders o, Product p)
join orderdetail od on od.IDHD = o.IDHD and od.IDSP = p.IDSP
where month(ngay) = 10 and year(ngay) = 2006
group by TenSP;

-- 37. Tính doanh thu từng tháng trong năm 2006
select month(Ngay) as 'Tháng', sum(TongGia) as 'Doanh thu' from Orders
where year(ngay) = 2006
group by month(Ngay);

-- 38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau
select idHD from orderdetail
group by idHD
having count(idHD) >= 4;

-- 39. Tìm hóa đơn có mua 3 sản phẩm khác nhau có giá < 300
select idHD, count(od.IdSP) from orderdetail od
join product p on p.idSP = od.idSP
where gia < 300
group by idHD
having count(od.idSP) = 3;

-- 40. Tìm MaKH, HoTen có số lần mua hàng nhiều nhất
              
-- 41. Doanh số bán hàng cao nhất thuộc về tháng nào 2006
select month(ngay) as 'Tháng', sum(TongGia) as 'Doanh thu' from Orders
where year(ngay) = 2006
group by Month(ngay)
order by sum(TongGia) desc
limit 1;

-- 42. Tìm MaSP, TenSP có tổng lượng bán ra thấp nhất 2006
select p.idSP, tensp, sum(soluong) from (product p, orders o)
join orderdetail od
on od.idSP = p.idSP and od.idHD = o.idHD 
where year(ngay) = 2006
group by p.idSP
order by sum(soluong)
limit 1;

-- 45. 10 khách hàng doanh số cao nhất


