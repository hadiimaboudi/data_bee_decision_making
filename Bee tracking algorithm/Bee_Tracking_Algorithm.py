import cv2
import numpy as np
import os
import pandas as pd
import matplotlib.pyplot as plt


# Replace with the path to your video file
video_path_directory = '/Volumes/BET lab/BET Lab/Science/BET lab in Sheffield/Projects/Active Decison-making/pythonProject/Videos/'
output_dir = '/Volumes/BET lab/BET Lab/Science/BET lab in Sheffield/Projects/Active Decison-making/pythonProject/results/'
video_name = 'IMG_0633.MOV'
video_path = os.path.join(video_path_directory, video_name)
t0_seconds = 1.0
t_end_seconds = 185
show_video = 1  # Set to 1 to show the video during processing

# Global variables to store mouse click locations
click_locations = []
N_clicks = 8  # Number of clicks before asking for confirmation
r_clicks = 65


def click_callback(event, x, y, flags, param):
    global click_locations

    if event == cv2.EVENT_LBUTTONDOWN:
        if len(click_locations) < 12:
            # Record the location of the clicks
            click_locations.append((x, y))

def read_and_process_frame(video_path, t0, N_clicks, click_r):
    global click_locations

    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        print("Error: Could not open video.")
        return None

    # Calculate the frame index at time t0
    frame_rate = cap.get(cv2.CAP_PROP_FPS)
    t0_frame = int(t0 * frame_rate)

    while True:
        ret, frame = cap.read()

        if not ret:
            break

        # Check if the current frame is the desired frame at time t0
        if cap.get(cv2.CAP_PROP_POS_FRAMES) == t0_frame:
            frame_copy = frame.copy()

            # Set up a mouse click callback
            cv2.namedWindow("Frame")
            cv2.setMouseCallback("Frame", click_callback)

            # Process mouse clicks
            while len(click_locations) < 12:
                cv2.imshow("Frame", frame_copy)
                cv2.waitKey(1)

                # Draw circles around each click location immediately after the click
                for i, (x, y) in enumerate(click_locations):
                    if i < 4:
                        # Yellow circles for the first four clicks
                        color = (0, 255, 255)  # Yellow (BGR format)
                    else:
                        # Red circles for the next four clicks
                        color = (0, 0, 255)  # Red (BGR format)

                    cv2.circle(frame_copy, (x, y), click_r, color, 2)  # Draw circles with radius click_r

                # Check if the number of clicks equals N_clicks
                if len(click_locations) == N_clicks:
                    cv2.imshow("Frame", frame_copy)

                    while True:
                        key = cv2.waitKey(0) & 0xFF

                        if key == ord('y'):
                            # User confirmed the selected centers, close the window and return click locations
                            cv2.destroyAllWindows()
                            return click_locations
                        elif key == ord('n'):
                            # User wants to retry, clear the click locations and redo the selection
                            click_locations = []
                            frame_copy = frame.copy()  # Reset the frame copy
                            break
                        else:
                            # Invalid key, continue waiting
                            continue

            # Show the frame with circles
            cv2.imshow("Frame", frame_copy)

    cap.release()
    cv2.destroyAllWindows()
    return click_locations

# Function to remove noise
def remove_noise(gray_diff, min_pixel_count):
    _, binary_diff = cv2.threshold(gray_diff, 30, 255, cv2.THRESH_BINARY)
    num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(binary_diff, connectivity=8)
    output = np.zeros_like(gray_diff, dtype=np.uint8)

    for label in range(1, num_labels):
        if stats[label, cv2.CC_STAT_AREA] >= min_pixel_count:
            output[labels == label] = 255

    return output

# Function to fit an ellipse to the detected object
def fit_ellipse_to_object(contour):
    if len(contour) < 5:
        angle = 0
        length = 0
    else:
        ellipse = cv2.fitEllipse(contour)
        angle = ellipse[2]
        length = max(ellipse[1])
    return angle, length

# Function to detect and draw circles in a frame
def detect_and_draw_circles(frame, K_hole, R):
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blurred_frame = cv2.GaussianBlur(gray_frame, (9, 9), 2)
    circles = cv2.HoughCircles(
        blurred_frame,
        cv2.HOUGH_GRADIENT,
        dp=1,
        minDist=20,
        param1=50,
        param2=30,
        minRadius=10,
        maxRadius=40,
    )

    detected_centers = []

    if circles is not None:
        circles = np.uint16(np.around(circles))
        for circle in circles[0, :]:
            x, y, radius = circle
            if np.pi * radius ** 2 > K_hole:
                detected_centers.append((x, y))
                cv2.circle(frame, (x, y), R, (0, 255, 255), -1)

    frame_hole = frame.copy()
    return detected_centers, frame_hole

# Function to process video frames and track objects
def process_video(video_path, output_dir, t0_seconds, t_end_seconds, show_video=1):
    N = 50
    min_object_area = 5
    tracked_objects = []
    ellipse_params = []
    frame_count = 0
    avg_frame = None
    show_image = 0
    tracking_history = []
    H = 100
    trajectory_data = []

    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        print("Error: Could not open video.")
        return

    frame_rate = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    t0_frame = int(t0_seconds * frame_rate)
    t_end_frame = int(t_end_seconds * frame_rate)

    if t_end_frame > total_frames:
        t_end_frame = total_frames -1

    if show_video:
        cv2.namedWindow('Video', cv2.WINDOW_NORMAL)
    avg_frame = None

    while True:
        ret, frame = cap.read()

        if not ret or frame_count > t_end_frame:
            break

        frame_count += 1
        current_time_seconds = frame_count / frame_rate

        if t0_frame <= frame_count <= t_end_frame:
            if avg_frame is None:
                avg_frame = np.float32(frame)

            if frame_count > 1:
                cv2.accumulateWeighted(frame, avg_frame, alpha=1.0 / N)

            frame_diff = cv2.absdiff(np.uint8(frame), np.uint8(avg_frame))
            gray_diff = cv2.cvtColor(frame_diff, cv2.COLOR_BGR2GRAY)
            min_pixel_count = 10
            filtered_gray_diff = remove_noise(gray_diff, min_pixel_count)

            key = cv2.waitKey(1) & 0xFF
            if key == ord('a'):
                show_image = 1

            if show_image == 1:
                plt.figure(figsize=(12, 6))
                plt.subplot(1, 2, 1)
                plt.imshow(filtered_gray_diff, cmap='gray')
                plt.title('Filtered Gray Difference Frame')

                gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                plt.subplot(1, 2, 2)
                plt.imshow(gray_frame, cmap='gray')
                plt.title('Gray Frame')

                plt.show()
                show_image = 0
                exit()

            _, binary_diff = cv2.threshold(filtered_gray_diff, 10, 255, cv2.THRESH_BINARY)
            contours, _ = cv2.findContours(binary_diff, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            max_area = 0
            max_contour = None

            for contour in contours:
                area = cv2.contourArea(contour)
                if area > min_object_area:
                    if area > max_area:
                        max_area = area
                        max_contour = contour

            if max_contour is not None:
                angle, length = fit_ellipse_to_object(max_contour)
                ellipse_params.append((angle, length))

                x, y, w, h = cv2.boundingRect(max_contour)
                tracked_objects.append((x + w // 2, y + h // 2))

                if len(tracked_objects) > H:
                    tracked_objects.pop(0)
                    ellipse_params.pop(0)

                for i in range(len(tracked_objects) - 1):
                    color_intensity = int(255 * (i + 1) / len(tracked_objects))
                    cv2.line(frame, tracked_objects[i], tracked_objects[i + 1], (0, 0, color_intensity), 2)

                    angle, length = ellipse_params[i]
                    angle_rad = np.deg2rad(angle)
                    x1 = int(tracked_objects[i][0] - length / 2 * np.cos(angle_rad + np.pi / 2))
                    y1 = int(tracked_objects[i][1] - length / 2 * np.sin(angle_rad + np.pi / 2))
                    x2 = int(tracked_objects[i][0] + length / 2 * np.cos(angle_rad + np.pi / 2))
                    y2 = int(tracked_objects[i][1] + length / 2 * np.sin(angle_rad + np.pi / 2))

                    line_color_with_alpha = (100, 100, 100, 0.5)
                    cv2.line(frame, (x1, y1), (x2, y2), line_color_with_alpha, 1)

                trajectory_data.append([current_time_seconds, x, y, angle, length])

            if current_time_seconds == t0_seconds:
                frame0 = frame.copy()
            if current_time_seconds == t_end_seconds:
                frame_end = frame.copy()

        if show_video:
            cv2.imshow('Video', frame)

        # Calculate and print time of current frame and processing percentage
        time_of_frame = current_time_seconds
        processing_percentage = ((frame_count - t0_frame) / (t_end_frame - t0_frame)) * 100

        print(f"Time of Frame: {time_of_frame:.2f} seconds | Processing Percentage: {processing_percentage:.2f}%")

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

    output_folder = os.path.join(output_dir, os.path.splitext(os.path.basename(video_path))[0])
    os.makedirs(output_folder, exist_ok=True)

    output_file = os.path.join(output_folder, os.path.splitext(os.path.basename(video_path))[0] + '_details.txt')
    with open(output_file, 'w') as file:
        file.write(f'Video Path: {video_path}\n')
        file.write(f'Frame Rate: {frame_rate}\n')
        file.write(f'Total Frames: {frame_count}\n')
        file.write(f'Start Time (seconds): {t0_seconds}\n')
        file.write(f'End Time (seconds): {t_end_seconds}\n')
        file.write('Trajectories:\n')

        for obj, params in zip(tracked_objects, ellipse_params):
            file.write(f'Location: {obj[0]},{obj[1]}, Angle: {params[0]}, Length: {params[1]}\n')

    trajectory_data_df = pd.DataFrame(trajectory_data,
                                      columns=['Time (s)', 'X Location', 'Y Location', 'Angle', 'Length'])
    output_excel_file = os.path.join(output_folder,
                                     os.path.splitext(os.path.basename(video_path))[0] + '_trajectories.xlsx')
    trajectory_data_df.to_excel(output_excel_file, index=False)

    frame_name = f"{frame_count:04d}.png"
    output_image_path = os.path.join(output_folder, frame_name)
    cv2.imwrite(output_image_path, frame0)

    # Convert click locations to a numpy array
    click_locations_array = np.array(click_locations)

    # Save click locations as a CSV file
    click_csv_file = os.path.join(output_folder, 'click_locations.csv')
    pd.DataFrame(click_locations_array, columns=['X', 'Y']).to_csv(click_csv_file, index=False)

    print("\nTracking completed. Trajectories and video details saved to the output folder.")



while True:
    click_locations = read_and_process_frame(video_path, t0_seconds, N_clicks, r_clicks)

    if click_locations:
        print("Click locations (x, y):")
        for i, (x, y) in enumerate(click_locations):
            print(f"Click {i + 1}: ({x}, {y})")

        confirm = input("Are the selected centers correct? (y/n): ").lower()
        if confirm == 'y':
            cv2.destroyAllWindows()  # Close the window
            break  # Exit the loop and continue with process_video

# Call the function to process the video
process_video(video_path, output_dir, t0_seconds, t_end_seconds, show_video)
