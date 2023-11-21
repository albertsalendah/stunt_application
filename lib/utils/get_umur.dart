
class GetUmur {

  String umur({required String tglLahir}) {
    int years = 0;
    int months = 0;
    int days = 0;

    if (tglLahir.isNotEmpty) {
      DateTime dateOfBirth = DateTime.parse(tglLahir);
      DateTime currentDate = DateTime.now();

      years = currentDate.year - dateOfBirth.year;
      months = currentDate.month - dateOfBirth.month;
      days = currentDate.day - dateOfBirth.day;

      if (days < 0) {
        months--;
        if (months < 0) {
          years--;
          months += 12;
        }
        days +=
            DateTime(dateOfBirth.year, dateOfBirth.month + months + 1, 0).day;
      }

      String yearStr = years > 1 ? 'Tahun' : 'Tahun';
      String monthStr = months > 1 ? 'Bulan' : 'Bulan';
      String dayStr = days > 1 ? 'Hari' : 'Hari';

      if (years == 0) {
        if (months == 0) {
          return '$days $dayStr';
        }
        return '$months $monthStr';
      } else if (months == 0) {
        return '$years $yearStr';
      } else {
        return '$years $yearStr and $months $monthStr';
      }
    } else {
      return '0 Tahun and 0 Bulan';
    }
  }

  bool cekUmur(String tglLahir) {
    if (tglLahir.isNotEmpty) {
      DateTime inputDate = DateTime.parse(tglLahir);
      DateTime currentDate = DateTime.now();

      int monthsDiff = currentDate.month -
          inputDate.month +
          12 * (currentDate.year - inputDate.year);
      return monthsDiff >= 12;
    } else {
      return false;
    }
  }

  int cekUmurBln(String tglLahir) {
    if (tglLahir.isNotEmpty) {
      DateTime inputDate = DateTime.parse(tglLahir);
      DateTime currentDate = DateTime.now();
      int monthsDiff = (currentDate.year - inputDate.year) * 12 +
          currentDate.month -
          inputDate.month;

      if (currentDate.day < inputDate.day) {
        monthsDiff--;
      }

      return monthsDiff;
    } else {
      return 0;
    }
  }

  List<int> Imtumur({required String tglLahir}) {
    int years = 0;
    int months = 0;

    if (tglLahir.isNotEmpty) {
      DateTime dateOfBirth = DateTime.parse(tglLahir);
      DateTime currentDate = DateTime.now();

      years = currentDate.year - dateOfBirth.year;
      months = currentDate.month - dateOfBirth.month;

      if (months < 0) {
        years--;
        months += 12;
      }

      return [years,months];
    } else {
      return [0,0];
    }
  }
}
