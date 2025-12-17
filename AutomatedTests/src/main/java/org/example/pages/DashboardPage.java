package org.example.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class DashboardPage extends BasePage {

    @FindBy(xpath = "//h1[contains(text(), 'Good Morning')]")
    private WebElement welcomeHeader;

    @FindBy(xpath = "/html/body/app-root/app-main-layout/div/app-sidebar/div/div[2]/button")
    private WebElement logoutButton;

    @FindBy(xpath = "//span[contains(text(), 'mindfulness streak')]")
    private WebElement streakText;

    @FindBy(xpath = "//a[contains(text(), 'Start Session') or contains(@href, 'chat')]")
    private WebElement chatLink;

    // Profile link is a div in the sidebar, not an anchor tag
    @FindBy(xpath = "//div[contains(@class, 'cursor-pointer') and .//span[text()='chevron_right']]")
    private WebElement profileLink;

    @FindBy(xpath = "//a[contains(@href, '/dashboard/games')]")
    private WebElement gamesLink;

    @FindBy(xpath = "//a[contains(@href, '/dashboard/mood')]")
    private WebElement moodLink;

    public DashboardPage(WebDriver driver) {
        super(driver);
    }

    public String getWelcomeText() {
        return welcomeHeader.getText();
    }

    public boolean isStreakVisible() {
        return streakText.isDisplayed();
    }

    public void goToProfile() {
        profileLink.click();
    }

    public void goToGames() {
        gamesLink.click();
    }

    public void goToMood() {
        moodLink.click();
    }

    public void goToChat() {
        chatLink.click();
    }

    public void logout() {
        logoutButton.click();
    }
}
