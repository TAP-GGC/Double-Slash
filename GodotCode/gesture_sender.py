import socket
import cv2
import mediapipe as mp
import time

# --------- UDP SOCKET SETUP ----------
UDP_IP = "127.0.0.1"
UDP_PORT = 5005

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# --------- MEDIAPIPE SETUP ----------
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils

hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
)

# ------------- COOLDOWN SETTINGS -------------
MENU_COOLDOWN = 1.2        # seconds before another A/B/C can be sent
STABLE_FRAMES = 10         # how many frames gesture must hold

last_menu_time = 0
gesture_buffer = 0
last_gesture = None

def get_fingers_up(hand_landmarks):
    fingers = []

    # Thumb
    fingers.append(
        hand_landmarks.landmark[4].x <
        hand_landmarks.landmark[3].x
    )

    tips = [8, 12, 16, 20]
    pips = [6, 10, 14, 18]

    for tip, pip in zip(tips, pips):
        fingers.append(
            hand_landmarks.landmark[tip].y <
            hand_landmarks.landmark[pip].y
        )

    return fingers

def classify_gesture(fingers, landmarks):
    thumb_tip = landmarks.landmark[4]
    thumb_ip = landmarks.landmark[3]

    # ---- MENU GESTURES (A/B/C) ----
    if fingers == [False, True, False, False, False]:
        return "ANSWER_A"

    if fingers == [False, True, True, False, False]:
        return "ANSWER_B"

    if fingers == [False, True, True, True, False]:
        return "ANSWER_C"

    # ---- MOVEMENT GESTURES ----
    if fingers == [True, False, False, False, False] and thumb_tip.y < thumb_ip.y:
        return "MOVE_RIGHT"

    if fingers == [True, False, False, False, False] and thumb_tip.y > thumb_ip.y:
        return "MOVE_LEFT"

    if fingers == [True, True, True, True, True]:
        return "MOVE_UP"

    if fingers == [False, False, False, False, False]:
        return "MOVE_DOWN"

    return None

cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(rgb)

    current_gesture = "STOP"

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_drawing.draw_landmarks(
                frame,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS
            )

            fingers = get_fingers_up(hand_landmarks)
            current_gesture = classify_gesture(fingers, hand_landmarks)

    now = time.time()

    # -------- MENU COOLDOWN + STABILIZATION --------
    if current_gesture in ["ANSWER_A", "ANSWER_B", "ANSWER_C"]:

        if current_gesture == last_gesture:
            gesture_buffer += 1
        else:
            gesture_buffer = 0

        if gesture_buffer >= STABLE_FRAMES:
            if now - last_menu_time > MENU_COOLDOWN:
                sock.sendto(current_gesture.encode(), (UDP_IP, UDP_PORT))
                print("SENT MENU:", current_gesture)

                last_menu_time = now
                gesture_buffer = 0

    # -------- MOVEMENT (NO COOLDOWN) --------
    elif current_gesture in ["MOVE_RIGHT", "MOVE_LEFT", "MOVE_UP", "MOVE_DOWN"]:
        sock.sendto(current_gesture.encode(), (UDP_IP, UDP_PORT))
        print("SENT MOVE:", current_gesture)

    last_gesture = current_gesture

    # ---- On-screen label ----
    if current_gesture:
        cv2.putText(
            frame,
            current_gesture,
            (10, 40),
            cv2.FONT_HERSHEY_SIMPLEX,
            1,
            (0, 255, 0),
            2
        )

    cv2.imshow("Gesture Sender", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
