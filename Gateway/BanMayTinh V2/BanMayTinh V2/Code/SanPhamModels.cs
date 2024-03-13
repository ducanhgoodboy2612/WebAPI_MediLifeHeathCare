using BanMayTinh_V2.Models;

namespace BanMayTinh_V2.Code
{
    public class SanPhamModels
    {
        public SanPham sanpham { get; set; }
        public List<ChiTietAnhSanPham> listchitiet { get; set; }
    }

    public class SanPhamEditModels
    {
        public SanPham sanpham { get; set; }
        public List<ChiTietAnhSanPhamEdit> listchitiet { get; set; }
    }
    public class ChiTietAnhSanPhamEdit
    {
        public int MaAnhChitiet { get; set; }
        public int? MaSanPham { get; set; }
        public string? Anh { get; set; }
        public int TrangThai { get; set; }
    }
}
