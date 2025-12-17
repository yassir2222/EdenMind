package org.example.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class GamesPage extends BasePage {

    @FindBy(xpath = "//h3[contains(text(), 'Breathing Exercise')]")
    private WebElement breathingGameCard;

    public GamesPage(WebDriver driver) {
        super(driver);
    }

    public void clickBreathingGame() {
        breathingGameCard.click();
    }
}
