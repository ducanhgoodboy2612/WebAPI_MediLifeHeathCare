using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_V2.Code;
using BanMayTinh_V2.Models;

namespace BanMayTinh_V2.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class KhachHangController : ControllerBase
    {
        private BanMayTinhContext db = new BanMayTinhContext();
        [Route("create-donhang")]
        [HttpPost]
        public IActionResult CreateDonHang(DonHangModels model)
        {
            try
            {
                db.KhachHangs.Add(model.khach);
                db.SaveChanges();
                var dh = new DonHang();
                dh.NgayDat = DateTime.Now;
                dh.TrangThaiDonHang = 1;
                dh.MaKhachHang = model.khach.MaKhachHang;
                db.DonHangs.Add(dh);
                db.SaveChanges();
                foreach (var x in model.listchitiet)
                    x.MaDonHang = dh.MaDonHang;
                dh.ChiTietDonHangs = model.listchitiet;
                db.SaveChanges();               
                return Ok("OK");
            }
            catch
            {
                return BadRequest();
            }
        }
    }
}
