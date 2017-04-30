class Admin::PhanMonsController < Admin::ApplicationController
  def index
    @khoas = Khoa.all
    @chuongtrinhdaotaos = ChuongTrinhDaoTao.all
    @search = Lop.search params[:q]

    if params[:info].present?
      if params[:info][:ten_khoa].present?
        @chuongtrinhdaotaos = ChuongTrinhDaoTao.where(khoa_id: params[:info][:ten_khoa])
        @search = Lop.where(chuong_trinh_dao_tao_id: ChuongTrinhDaoTao.where(khoa_id: params[:info][:ten_khoa])).search params[:q]
        if params[:info][:ten_ctdt].present?
          @search = Lop.where(chuong_trinh_dao_tao_id: ChuongTrinhDaoTao.where(id: params[:info][:ten_ctdt] )).search params[:q]
        end
      end
    end

    @search.sorts  = "created_at desc" if @search.sorts.empty?
    @lops = @search.result.page(params[:page]).per 5

  end

  def show
  end

  def new
    @lop = Lop.find_by(id: params[:lop])
    @chuongtrinhdaotao = @lop.chuong_trinh_dao_tao
    @chitietdaotaos = ChiTietDaoTao.where(chuong_trinh_dao_tao_id: @chuongtrinhdaotao)
    @giaoviens = GiaoVien.where(khoa_id: @chuongtrinhdaotao.khoa)
    @kyhoc = params[:kyhoc]

    @all_phanmon_cualop = PhanMon.where(hocky: @kyhoc, chuong_trinh_dao_tao_id: @chuongtrinhdaotao, lop_id: @lop)

    chitietdaotaos_daphanmon = ChiTietDaoTao.where(chuong_trinh_dao_tao_id: @chuongtrinhdaotao, mon_hoc_id: @all_phanmon_cualop.pluck(:mon_hoc_id))

    @chitietdaotaos = @chitietdaotaos - chitietdaotaos_daphanmon
  end

  def edit
  end

  def create
    list_mon_hoc = params[:list_mon_hoc]
    lish_thong_tin = params[:list_thong_tin]
    capnhat_phanmon = []
    taomoi_phanmon = []

    if list_mon_hoc.present?
      list_mon_hoc.each do |key, value|
        kiem_tra_phanmon = PhanMon.where(hocky: lish_thong_tin.last, chuong_trinh_dao_tao_id: lish_thong_tin.first, lop_id: lish_thong_tin.second, mon_hoc_id: value[0])
        if kiem_tra_phanmon.present?
          capnhat_item = kiem_tra_phanmon.update(sotiet: value[2], giao_vien_id: value[1])
          capnhat_phanmon = capnhat_phanmon.push capnhat_item.first
        else
          taomoi_item = PhanMon.create(hocky: lish_thong_tin.last, sotiet: value[2], giao_vien_id: value[1], chuong_trinh_dao_tao_id: lish_thong_tin.first, mon_hoc_id: value[0], lop_id: lish_thong_tin.second)
          taomoi_phanmon =  taomoi_phanmon.push taomoi_item
        end
      end
    end

    all_phanmon_cualop = PhanMon.where(hocky: lish_thong_tin.last, chuong_trinh_dao_tao_id: lish_thong_tin.first, lop_id: lish_thong_tin.second)
    monhoc_can_xoa = all_phanmon_cualop - (capnhat_phanmon + taomoi_phanmon)
    if monhoc_can_xoa.present?
      PhanMon.where(id: monhoc_can_xoa).destroy_all
    end
  end
end
