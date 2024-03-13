using System;
using System.Collections.Generic;

namespace BanMayTinh_V2.Models
{
    public partial class DonHang
    {
        public DonHang()
        {
            ChiTietDonHangs = new HashSet<ChiTietDonHang>();
        }

        public int MaDonHang { get; set; }
        public int? MaKhachHang { get; set; }
        public DateTime? NgayDat { get; set; }
        public int? TrangThaiDonHang { get; set; }

        public virtual ICollection<ChiTietDonHang> ChiTietDonHangs { get; set; }
    }
}
