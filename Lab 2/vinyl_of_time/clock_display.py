from PIL import Image, ImageDraw, ImageFont
import board
import digitalio
import adafruit_ssd1306


class DisplayManager:
    def __init__(self):
        # Initialize display (adjust for your specific display)
        i2c = board.I2C()
        self.display = adafruit_ssd1306.SSD1306_I2C(128, 64, i2c)

    def update_display(self, song_info):
        """Update the OLED display with current song information"""
        self.display.fill(0)
        image = Image.new("1", (self.display.width, self.display.height))
        draw = ImageDraw.Draw(image)

        # Draw time
        current_time = datetime.now().strftime("%H:00")
        draw.text((0, 0), current_time,
                  font=ImageFont.load_default(), fill=255)

        # Draw song info
        if song_info:
            draw.text((0, 20), song_info['title'], fill=255)
            draw.text((0, 35), song_info['artist'], fill=255)

        self.display.image(image)
        self.display.show()
