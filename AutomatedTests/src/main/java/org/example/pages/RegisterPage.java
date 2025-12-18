package org.example.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class RegisterPage extends BasePage {

    @FindBy(css = "input[formControlName='firstName']")
    private WebElement firstNameInput;

    @FindBy(css = "input[formControlName='lastName']")
    private WebElement lastNameInput;

    @FindBy(css = "input[formControlName='email']")
    private WebElement emailInput;

    @FindBy(css = "input[formControlName='password']")
    private WebElement passwordInput;

    @FindBy(css = "button[type='submit']")
    private WebElement submitButton;

    public RegisterPage(WebDriver driver) {
        super(driver);
    }

    public void register(String firstName, String lastName, String email, String password) {
        firstNameInput.clear();
        firstNameInput.sendKeys(firstName);

        lastNameInput.clear();
        lastNameInput.sendKeys(lastName);

        emailInput.clear();
        emailInput.sendKeys(email);

        passwordInput.clear();
        passwordInput.sendKeys(password);

        // Wait for Angular validation if necessary, but usually typing triggers it
        wait.until(d -> submitButton.isEnabled());
        submitButton.click();
    }
}
