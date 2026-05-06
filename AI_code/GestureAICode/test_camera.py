import cv2
import mediapipe as mp

# ---------------- MediaPipe Setup ----------------
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils

hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
)

# ---------------- Gesture → Game Action Mapping ----------------
GESTURE_MAP = {
    "OPTION_1": "ANSWER_A",
    "OPTION_2": "ANSWER_B",
    "OPTION_3": "ANSWER_C",
    "MOVE_RIGHT": "ui_right",
    "MOVE_LEFT": "ui_left",
    "JUMP": "jump",
    "CROUCH": "crouch"
}

# ---------------- Stabilization ----------------
STABLE_FRAMES = 10
COOLDOWN_FRAMES = 20

gesture_buffer = 0
last_gesture = None
cooldown = 0

# ---------------- Finger Detection ----------------
def get_fingers_up(hand_landmarks):
    fingers = []

    # Thumb
    fingers.append(
        hand_landmarks.landmark[4].x <
        hand_landmarks.landmark[3].x
    )

    # Other fingers
    tips = [8, 12, 16, 20]
    pips = [6, 10, 14, 18]

    for tip, pip in zip(tips, pips):
        fingers.append(
            hand_landmarks.landmark[tip].y <
            hand_landmarks.landmark[pip].y
        )

    return fingers

# ---------------- Gesture Classification ----------------
def classify_gesture(fingers, landmarks):
    thumb_tip = landmarks.landmark[4]
    thumb_ip = landmarks.landmark[3]

    # --- Menu answers (A/B/C) ---
    if fingers == [False, True, False, False, False]:
        return "OPTION_1"   # A

    if fingers == [False, True, True, False, False]:
        return "OPTION_2"   # B

    if fingers == [False, True, True, True, False]:
        return "OPTION_3"   # C

    # --- Movement controls ---
    if fingers == [True, False, False, False, False] and thumb_tip.y < thumb_ip.y:
        return "MOVE_RIGHT"

    if fingers == [True, False, False, False, False] and thumb_tip.y > thumb_ip.y:
        return "MOVE_LEFT"

    if fingers == [True, True, True, True, True]:
        return "JUMP"

    if fingers == [False, False, False, False, False]:
        return "CROUCH"

    return None

# ----------------------------------------------------
#                   MAIN PROGRAM
# ----------------------------------------------------
cap = cv2.VideoCapture(0)

print("\nGesture system started (NO CALIBRATION).")
print("Press 'q' to quit.\n")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(rgb)

    current_gesture = None

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_drawing.draw_landmarks(
                frame,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS
            )

            fingers = get_fingers_up(hand_landmarks)
            current_gesture = classify_gesture(fingers, hand_landmarks)

    # ---- Stabilization for menu choices (A/B/C) ----
    if current_gesture and current_gesture.startswith("OPTION"):
        if cooldown > 0:
            cooldown -= 1
        else:
            if current_gesture == last_gesture:
                gesture_buffer += 1
            else:
                gesture_buffer = 0

            if gesture_buffer >= STABLE_FRAMES:
                action = GESTURE_MAP[current_gesture]
                print(f"MENU ACTION → {action}")
                cooldown = COOLDOWN_FRAMES
                gesture_buffer = 0

    # ---- Continuous movement gestures ----
    if current_gesture in ["MOVE_RIGHT", "MOVE_LEFT", "JUMP", "CROUCH"]:
        action = GESTURE_MAP[current_gesture]
        print(f"MOVE ACTION → {action}")

    last_gesture = current_gesture

    # Show detected gesture on screen
    if current_gesture:
        cv2.putText(
            frame,
            f"Gesture: {current_gesture}",
            (10, 40),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 255, 0),
            2
        )

    cv2.imshow("Gesture Control System", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
