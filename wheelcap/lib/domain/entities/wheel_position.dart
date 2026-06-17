enum WheelPosition { frontLeft, frontRight, rearLeft, rearRight }

/// 현재 차량에는 ProxAlert 센서가 한 대만 장착되어 있어, 4코너 중
/// 이 위치에만 실시간 데이터가 반영된다. 센서를 다른 바퀴로 옮기면
/// 이 값만 바꾸면 된다.
const WheelPosition activeWheelPosition = WheelPosition.frontLeft;
