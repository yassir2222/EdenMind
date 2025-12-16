package org.example.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

import java.util.List;

public class MoodPage extends BasePage {

    @FindBy(tagName = "h2")
    private WebElement header;

    @FindBy(xpath = "//button[contains(text(), 'Log Mood')]")
    private WebElement logMoodButton;

    // Mood buttons are simple text buttons now
    @FindBy(xpath = "//button[contains(@class, 'rounded-full') and contains(@class, 'hover:bg-eden-soothing')]")
    private List<WebElement> moodButtons;

    public MoodPage(WebDriver driver) {
        super(driver);
    }

    public boolean isLoaded() {
        return driver.getCurrentUrl().contains("/mood");
    }

    public void openLogForm() {
        if (moodButtons.isEmpty() || !moodButtons.get(0).isDisplayed()) {
            logMoodButton.click();
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
            }
        }
    }

    public int getMoodOptionCount() {
        openLogForm();
        return moodButtons.size();
    }
}
