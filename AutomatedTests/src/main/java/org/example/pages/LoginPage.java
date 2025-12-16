package org.example.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class LoginPage extends BasePage {

    @FindBy(css = "input[formControlName='email']")
    private WebElement emailInput;

    @FindBy(css = "input[formControlName='password']")
    private WebElement passwordInput;

    @FindBy(css = "button[type='submit']")
    private WebElement loginButton;

    @FindBy(css = "a[href='/register']")
    private WebElement registerLink;

    @FindBy(className = "text-red-500") // Assuming error class based on Tailwind
    private WebElement errorMessage;

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    public void navigateTo() {
        driver.get("http://localhost:4200/login");
    }

    public void login(String email, String password) {
        emailInput.clear();
        emailInput.sendKeys(email);
        passwordInput.clear();
        passwordInput.sendKeys(password);

        // Wait for Angular validation to enable the button
        wait.until(d -> loginButton.isEnabled());
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
        } // Stabilize
        loginButton.click();
    }

    public void clickRegister() {
        registerLink.click();
    }

    public String getErrorMessage() {
        return errorMessage.getText();
    }
}
