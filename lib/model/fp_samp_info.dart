
// FPサンプリングデータ
class FpSampInfo {
  double Fx = 0;
  double Fy = 0;
  double Fz = 0;
  double Mx = 0;
  double My = 0;
  double Mz = 0;
  int IDNum = 0; // ID番号
  int syncLine = 0; // 同期信号
  DateTime rxDt = DateTime.now(); // 受信時刻
  int rxCnt = 0;
}
