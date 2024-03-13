﻿using System;
using System.Collections.Generic;

namespace BanMayTinh_V2.Models
{
    public partial class ChiTietAnhSanPham
    {
        public int MaAnhChitiet { get; set; }
        public int? MaSanPham { get; set; }
        public string? Anh { get; set; }

        public virtual SanPham? MaSanPhamNavigation { get; set; }
    }
}
