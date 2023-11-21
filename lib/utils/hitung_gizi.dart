import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stunt_application/models/stsGZ.dart';

import '../custom_widget/popup_status_gizi.dart';
import '../models/data_anak_model.dart';
import '../models/data_imt_5_18.dart';
import '../models/data_tabel_status_gizi_model.dart';

class HitungGizi {
  void beratBadanperUmur(
      {required BuildContext context,
      required DataAnakModel dataAnak,
      required int umurBln,
      required List<DataTabelStatusGizi> list_bb_umur}) {
    DataTabelStatusGizi res = list_bb_umur
        .firstWhere((element) => element.umur_panjang_tinggi == umurBln);

    double median = res.median ?? 0;
    double bbMedian = double.parse(dataAnak.beratbadan ?? '0') - median;
    double sd = bbMedian > 0
        ? res.p1SD ?? 0
        : bbMedian < 0
            ? res.m1SD ?? 0
            : res.p1SD ?? 0;
    double sdMedian = bbMedian < 0 ? median - sd : sd - median;
    double result = bbMedian / sdMedian;
    log('BB/U -> $result');
    if (result < -3) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Berat Badan Sangat Kurang',
            message: 'Severely Underweight'),
      );
    } else if (result < -2) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Berat Badan Kurang', message: 'Underweight'),
      );
    } else if (result < 1) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Berat Badan Normal', message: ''),
      );
    } else if (result <= 2) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Resiko Berat Badan Lebih', message: ''),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Berat Badan Lebih', message: ''),
      );
    }
  }

  void tinggibadanUmur(
      {required BuildContext context,
      required DataAnakModel dataAnak,
      required int umurBln,
      required List<DataTabelStatusGizi> list_tb_umur,
      required String selectedPengukuran}) {
    DataTabelStatusGizi res = list_tb_umur
        .firstWhere((element) => element.umur_panjang_tinggi == umurBln);
    double median = res.median ?? 0;
    double tinggiMedian = umurBln == 24
        ? selectedPengukuran == 'Dikukur Terlentang'
            ? double.parse(dataAnak.tinggibadan ?? '0') - median
            : (double.parse(dataAnak.tinggibadan ?? '0') - 0.7) - median
        : double.parse(dataAnak.tinggibadan ?? '0') - median;
    double sd = tinggiMedian > 0
        ? res.p1SD ?? 0
        : tinggiMedian < 0
            ? res.m1SD ?? 0
            : res.p1SD ?? 0;
    double sdMedian = tinggiMedian < 0 ? median - sd : sd - median;
    double result = tinggiMedian / sdMedian;
    log('TB/U _> $result');
    if (result < -3) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Sangat Pendek', message: 'Severely Stunted'),
      );
    } else if (result < -2) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Pendek', message: 'Stunted'),
      );
    } else if (result <= 3) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Normal', message: ''),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Tinggi', message: ''),
      );
    }
  }

  void beratPanjangBadan(
      {required BuildContext context,
      required DataAnakModel dataAnak,
      required int umurBln,
      required List<DataTabelStatusGizi> list_bb_pb}) {
    DataTabelStatusGizi res = list_bb_pb.firstWhere((element) =>
        element.umur_panjang_tinggi! >=
        double.parse(dataAnak.tinggibadan ?? '0'));
    double median = res.median ?? 0;
    double bbMedian = double.parse(dataAnak.beratbadan ?? '0') - median;
    double sd = bbMedian > 0
        ? res.p1SD ?? 0
        : bbMedian < 0
            ? res.m1SD ?? 0
            : res.p1SD ?? 0;
    double sdMedian = bbMedian < 0 ? median - sd : sd - median;
    double result = bbMedian / sdMedian;
    log('BB/U -> $result');
    if (result < -3) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Gizi buruk', message: 'Severely Wasted'),
      );
    } else if (result < -2) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi kurang', message: 'Wasted'),
      );
    } else if (result < 1) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi baik', message: ''),
      );
    } else if (result < 2) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Berisiko Gizi Lebih ',
            message: 'Possible Risk of Overweight'),
      );
    } else if (result <= 3) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi lebih', message: 'Overweight'),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Obesitas', message: 'Obese'),
      );
    }
  }

  void beratTinggiBadan(
      {required BuildContext context,
      required DataAnakModel dataAnak,
      required int umurBln,
      required List<DataTabelStatusGizi> list_bb_tb}) {
    DataTabelStatusGizi res = list_bb_tb.firstWhere((element) =>
        element.umur_panjang_tinggi! >=
        double.parse(dataAnak.tinggibadan ?? '0'));
    double median = res.median ?? 0;
    double bbMedian = double.parse(dataAnak.beratbadan ?? '0') - median;
    double sd = bbMedian > 0
        ? res.p1SD ?? 0
        : bbMedian < 0
            ? res.m1SD ?? 0
            : res.p1SD ?? 0;
    double sdMedian = bbMedian < 0 ? median - sd : sd - median;
    double result = bbMedian / sdMedian;
    log('BB/U 5 -> $result');
    if (result < -3) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Gizi buruk', message: 'Severely Wasted'),
      );
    } else if (result < -2) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi kurang', message: 'Wasted'),
      );
    } else if (result < 1) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi baik', message: ''),
      );
    } else if (result < 2) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Berisiko Gizi Lebih ',
            message: 'Possible Risk of Overweight'),
      );
    } else if (result <= 3) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi lebih', message: 'Overweight'),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Obesitas', message: 'Obese'),
      );
    }
  }

  void imtUmur(
      {required BuildContext context,
      required DataAnakModel dataAnak,
      required int umurBln,
      required List<DataTabelStatusGizi> list_imt_umur}) {
    DataTabelStatusGizi res = list_imt_umur
        .firstWhere((element) => element.umur_panjang_tinggi == umurBln);
    double imt = (double.parse(dataAnak.beratbadan ?? '0') /
            (double.parse(dataAnak.tinggibadan ?? '0') / 100)) /
        (double.parse(dataAnak.tinggibadan ?? '0') / 100);
    double median = res.median ?? 0;
    double imtMedian = imt - median;
    double sd = imtMedian > 0
        ? res.p1SD ?? 0
        : imtMedian < 0
            ? res.m1SD ?? 0
            : res.p1SD ?? 0;
    double sdMedian = imtMedian < 0 ? median - sd : sd - median;
    double result = imtMedian / sdMedian;
    if (result < -3) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Gizi buruk', message: 'Severely Wasted'),
      );
    } else if (result < -2) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi kurang', message: 'Wasted'),
      );
    } else if (result < 1) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi baik', message: ''),
      );
    } else if (result < 2) {
      showDialog(
        context: context,
        builder: (context) => const PopUpStatusGizi(
            title: 'Berisiko Gizi Lebih ',
            message: 'Possible Risk of Overweight'),
      );
    } else if (result <= 3) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi lebih', message: 'Overweight'),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Obesitas', message: 'Obese'),
      );
    }
  }

  void imtUmur518(
      {required BuildContext context,
      required DataAnakModel dataAnak,
      required int umurBln,
      required List<DataIMT> list_imt_umur_518,
      required List<int> umurTahun}) {
    DataIMT res = list_imt_umur_518.firstWhere((element) =>
        element.tahun == umurTahun[0] && element.bulan == umurTahun[1]);
    double imt = (double.parse(dataAnak.beratbadan ?? '0') /
            (double.parse(dataAnak.tinggibadan ?? '0') / 100)) /
        (double.parse(dataAnak.tinggibadan ?? '0') / 100);
    double median = res.median ?? 0;
    double imtMedian = imt - median;
    double sd = imtMedian > 0
        ? res.p1SD ?? 0
        : imtMedian < 0
            ? res.m1SD ?? 0
            : res.p1SD ?? 0;
    double sdMedian = imtMedian < 0 ? median - sd : sd - median;
    double result = imtMedian / sdMedian;
    if (result < -2) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi kurang', message: 'Thinness'),
      );
    } else if (result < 1) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi baik', message: ''),
      );
    } else if (result < 2) {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Gizi lebih', message: 'Overweight'),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpStatusGizi(title: 'Obesitas', message: 'Obese'),
      );
    }
  }

  StsGZ getStatusGizi(
      {required BuildContext context,
      required DataAnakModel dataAnak,
      required int umurBln,
      required List<DataIMT> list_imt_umur_518,
      required List<DataTabelStatusGizi> list_imt_umur,
      required List<int> umurTahun}) {
    if (umurBln >= 60) {
      DataIMT res = list_imt_umur_518.firstWhere((element) =>
          element.tahun == umurTahun[0] && element.bulan == umurTahun[1]);
      double imt = (double.parse(dataAnak.beratbadan ?? '0') /
              (double.parse(dataAnak.tinggibadan ?? '0') / 100)) /
          (double.parse(dataAnak.tinggibadan ?? '0') / 100);
      double median = res.median ?? 0;
      double imtMedian = imt - median;
      double sd = imtMedian > 0
          ? res.p1SD ?? 0
          : imtMedian < 0
              ? res.m1SD ?? 0
              : res.p1SD ?? 0;
      double sdMedian = imtMedian < 0 ? median - sd : sd - median;
      double result = imtMedian / sdMedian;
      if (result < -2) {
        return StsGZ(color: Colors.red[900], status: 'Gizi kurang (IMT/U)');
      } else if (result < 1) {
        return StsGZ(color: Colors.green, status: 'Gizi Baik (IMT/U)');
      } else if (result < 2) {
        return StsGZ(color: Colors.orange[900], status: 'Gizi lebih (IMT/U)');
      } else {
        return StsGZ(color: Colors.red[900], status: 'Obesitas (IMT/U)');
      }
    } else {
      DataTabelStatusGizi res = list_imt_umur
          .firstWhere((element) => element.umur_panjang_tinggi == umurBln);
      double imt = (double.parse(dataAnak.beratbadan ?? '0') /
              (double.parse(dataAnak.tinggibadan ?? '0') / 100)) /
          (double.parse(dataAnak.tinggibadan ?? '0') / 100);
      double median = res.median ?? 0;
      double imtMedian = imt - median;
      double sd = imtMedian > 0
          ? res.p1SD ?? 0
          : imtMedian < 0
              ? res.m1SD ?? 0
              : res.p1SD ?? 0;
      double sdMedian = imtMedian < 0 ? median - sd : sd - median;
      double result = imtMedian / sdMedian;
      if (result < -3) {
        return StsGZ(color: Colors.red[900], status: 'Gizi buruk (IMT/U)');
      } else if (result < -2) {
        return StsGZ(color: Colors.red[400], status: 'Gizi kurang (IMT/U)');
      } else if (result < 1) {
        return StsGZ(color: Colors.green, status: 'Gizi Baik (IMT/U)');
      } else if (result < 2) {
        return StsGZ(color: Colors.orange, status: 'Berisiko Gizi Lebih (IMT/U)');
      } else if (result <= 3) {
        return StsGZ(color: Colors.red[400], status: 'Gizi lebih (IMT/U)');
      } else {
        return StsGZ(color: Colors.red[900], status: 'Obesitas (IMT/U)');
      }
    }
  }
}
