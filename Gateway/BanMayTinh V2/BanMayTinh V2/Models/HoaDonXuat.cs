using System;
using System.Collections.Generic;

namespace BanMayTinh_V2.Models
{
    public partial class HoaDonXuat
    {
        public HoaDonXuat()
        {
            ChiTietHoaDonXuats = new HashSet<ChiTietHoaDonXuat>();
        }

        public int MaHoaDonXuat { get; set; }
        public string? SoHoaDon { get; set; }
        public DateTime? NgayXuat { get; set; }
        public int? MaKhachHang { get; set; }
        public int? MaNguoiDung { get; set; }

        public virtual KhachHang? MaKhachHangNavigation { get; set; }
        public virtual ICollection<ChiTietHoaDonXuat> ChiTietHoaDonXuats { get; set; }
    }
}
