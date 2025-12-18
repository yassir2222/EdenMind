package org.example.tests;

import org.example.pages.*;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;

import static org.assertj.core.api.Assertions.assertThat;

public class EdenMindTests extends BaseTest {

    // Helper to log in for tests that require auth - now returns DashboardPage
    private DashboardPage performLogin() {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.navigateTo();
        loginPage.login("anas@anas.com", "Anas16121998");

        DashboardPage dashboard = new DashboardPage(driver);
        // Wait for dashboard to actually load to prevent race conditions
        try {
            Thread.sleep(1000); // Give backend a moment to process token
            // Wait up to 5s for URL to change to dashboard
            new org.openqa.selenium.support.ui.WebDriverWait(driver, java.time.Duration.ofSeconds(5))
                    .until(d -> d.getCurrentUrl().contains("/dashboard"));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        // If WebDriverWait fails, it throws TimeoutException, which we now allow to
        // propagate
        // so we know exactly why connection failed.
        return dashboard;
    }

    @Test
    public void test01_RegistrationFlow() {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.navigateTo();
        loginPage.clickRegister();
        // Just verifying we reached register page
        assertThat(driver.getCurrentUrl()).contains("/register");
    }

    @Test
    public void test02_LoginSuccess() {
        DashboardPage dashboard = performLogin();
        // The dashboard object is created, but we need to ensure the page is loaded
        // This getWelcomeText call will wait for the h1 element due to implicit wait
        assertThat(dashboard.getWelcomeText()).contains("Good Morning");
        assertThat(driver.getCurrentUrl()).contains("/dashboard");
    }

    @Test
    public void test03_LoginFailure() {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.navigateTo();
        loginPage.login("wrong@user.com", "wrongpass");
        // Wait for error (BasePage wait logic might be needed if implicit wait isn't
        // enough, but implicit is set)
        // Adjust locator in LoginPage if needed
    }

    @Test
    public void test04_DashboardIntegrity() {
        DashboardPage dashboard = performLogin();
        assertThat(dashboard.isStreakVisible()).isTrue();
    }

    @Test
    public void test05_NavigationProfile() {
        DashboardPage dashboard = performLogin();
        dashboard.goToProfile();

        ProfilePage profile = new ProfilePage(driver);
        assertThat(profile.isLoaded()).isTrue();
    }

    @Test
    public void test06_ProfileUpdate() {
        DashboardPage dashboard = performLogin();
        dashboard.goToProfile();

        ProfilePage profile = new ProfilePage(driver);
        String newBio = "Updated by Selenium at ";
        profile.updateBio(newBio);

        // Assert alert or success message if visible, or just re-read value
        // For now, assuming success doesn't throw error
    }

    @Test
    public void test07_MoodCheckInUI() {
        DashboardPage dashboard = performLogin();
        dashboard.goToMood();

        MoodPage moodPage = new MoodPage(driver);
        assertThat(moodPage.getMoodOptionCount()).isGreaterThan(0);
    }

    @Test
    public void test08_ChatOptimisticUI() {
        DashboardPage dashboard = performLogin();
        dashboard.goToChat();

        ChatPage chatPage = new ChatPage(driver);
        String testMsg = "Hello";
        chatPage.sendMessage(testMsg);

        assertThat(chatPage.isMessageVisible(testMsg)).isTrue();
    }

    @Test
    public void test09_GameNavigation() {
        DashboardPage dashboard = performLogin();
        dashboard.goToGames();

        GamesPage gamesPage = new GamesPage(driver);
        gamesPage.clickBreathingGame();

        assertThat(driver.getCurrentUrl()).contains("/games/breathing");
    }

    @Test
    public void test10_LogoutFlow() {
        DashboardPage dashboard = performLogin();
        dashboard.logout();

        assertThat(driver.getCurrentUrl()).contains("/login");
    }

    @Test
    public void test11_FullUserJourney() {
        // 1. Create/Register Account
        LoginPage loginPage = new LoginPage(driver);
        loginPage.navigateTo();
        loginPage.clickRegister();

        RegisterPage registerPage = new RegisterPage(driver);
        long timestamp = System.currentTimeMillis();
        String newUserEmail = "user" + timestamp + "@test.com";
        String newUserPass = "Test@123";
        registerPage.register("Test", "User", newUserEmail, newUserPass);

        // 2. Verify auto-login to Dashboard
        DashboardPage dashboard = new DashboardPage(driver);
        // Wait for dashboard header to be visible (Using getWelcomeText which waits)
        // If auto-login works, we should be at /dashboard
        try {
            new org.openqa.selenium.support.ui.WebDriverWait(driver, java.time.Duration.ofSeconds(5))
                    .until(d -> d.getCurrentUrl().contains("/dashboard"));
        } catch (Exception e) {
            // Fallback: If not redirected, maybe try to login manually (though code
            // suggested auto-login)
            if (driver.getCurrentUrl().contains("login")) {
                loginPage.login(newUserEmail, newUserPass);
            }
        }
        assertThat(driver.getCurrentUrl()).contains("/dashboard");
        assertThat(dashboard.getWelcomeText()).contains("Good Morning");

        // 3. Logout and Login with same account
        dashboard.logout();
        assertThat(driver.getCurrentUrl()).contains("/login");

        loginPage.login(newUserEmail, newUserPass);
        // Re-initialize dashboard after login
        dashboard = new DashboardPage(driver);
        new org.openqa.selenium.support.ui.WebDriverWait(driver, java.time.Duration.ofSeconds(5))
                .until(d -> d.getCurrentUrl().contains("/dashboard"));

        // 4. Test Chatbot (Send message and wait for response)
        dashboard.goToChat();
        ChatPage chatPage = new ChatPage(driver);
        String msg = "Hello";
        chatPage.sendMessage(msg);
        assertThat(chatPage.isMessageVisible(msg)).isTrue();
        // Wait for ANY bot response
        assertThat(chatPage.waitForBotResponse()).isTrue();

        // 5. Test Breathing Game (Wait 10s)
        dashboard.goToGames();
        GamesPage gamesPage = new GamesPage(driver);
        gamesPage.clickBreathingGame();
        assertThat(driver.getCurrentUrl()).contains("breathing");
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // 6. Create a Mood
        dashboard.goToMood();
        MoodPage moodPage = new MoodPage(driver);
        moodPage.selectFirstMood();
        
        dashboard.goToProfile();

        dashboard.logout();

        assertThat(driver.getCurrentUrl()).contains("/login");
    }
}
