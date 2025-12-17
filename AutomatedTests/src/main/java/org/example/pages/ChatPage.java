package org.example.pages;

import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

import java.util.List;

public class ChatPage extends BasePage {

    @FindBy(name = "message")
    private WebElement messageInput;

    @FindBy(css = "button[type='submit']")
    private WebElement sendButton;

    // Selects user messages (blue bubbles)
    @FindBy(className = "bg-eden-blue")
    private List<WebElement> userMessages;

    public ChatPage(WebDriver driver) {
        super(driver);
    }

    public void sendMessage(String text) {
        messageInput.sendKeys(text);
        sendButton.click();
    }

    public boolean isMessageVisible(String text) {
        try {
            return wait.until(d -> {
                List<WebElement> messages = d.findElements(org.openqa.selenium.By.className("bg-eden-blue"));
                for (WebElement msg : messages) {
                    if (msg.getText().contains(text)) {
                        return true;
                    }
                }
                return false;
            });
        } catch (Exception e) {
            return false;
        }
    }
}
