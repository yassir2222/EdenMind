package org.example.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class ProfilePage extends BasePage {

    @FindBy(tagName = "h2")
    private WebElement pageHeader;

    // Using css selector for Angular formControlName
    @FindBy(css = "textarea[formControlName='bio']")
    private WebElement bioInput;

    @FindBy(css = "button[type='submit']")
    private WebElement saveButton;

    public ProfilePage(WebDriver driver) {
        super(driver);
    }

    public boolean isLoaded() {
        return driver.getCurrentUrl().contains("/profile") && pageHeader.getText().equals("Your Profile");
    }

    public void updateBio(String newBio) {
        bioInput.clear();
        bioInput.sendKeys(newBio);
        saveButton.click();
    }
}
