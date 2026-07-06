---
name: update-icons
description: Updates the app launcher icons for iOS, Android, and Web based on a provided image file, URL, or generation prompt.
---

# Update Icons Skill

This skill handles updating the Flutter launcher icons for the project across all platforms (Android, iOS, Web).

## Instructions for the Agent

When triggered, you must perform the following steps:

1. **Obtain the Image**:
   - Determine how the user provided the logo (e.g., file path, URL, or generation prompt).
   - If a prompt is provided, use the `generate_image` tool to create the icon.
   - If a URL or file is provided, download or copy it.
   - Save the final image to `assets/icon/app_icon.png`.

2. **Configure `flutter_launcher_icons`**:
   - Modify `flutter_launcher_icons.yaml` using the `write_to_file` or `multi_replace_file_content` tool.
   - Ensure the configuration points `image_path` to `assets/icon/app_icon.png`.
   - Ensure that `adaptive_icon_background` and `theme_color` are updated to match the primary brand color of the new logo (if provided).
   - A standard configuration looks like this:
     ```yaml
     flutter_launcher_icons:
       android: true
       ios: true
       image_path: assets/icon/app_icon.png
       adaptive_icon_background: "#FFFFFF"
       adaptive_icon_foreground: assets/icon/app_icon.png
       web:
         generate: true
         image_path: assets/icon/app_icon.png
         background_color: "#FFFFFF"
         theme_color: "#FFFFFF"
       windows:
         generate: true
         image_path: assets/icon/app_icon.png
       macos:
         generate: true
         image_path: assets/icon/app_icon.png
     ```

3. **Generate Icons**:
   - Run the following terminal command to build the native icons:
     ```bash
     dart run flutter_launcher_icons
     ```

4. **Update Web Favicon**:
   - Copy the newly created icon to the web directory so it is used as the browser tab icon:
     ```bash
     cp assets/icon/app_icon.png web/favicon.png
     ```

5. **Completion**:
   - Notify the user that the app icons have been successfully updated across all platforms.
