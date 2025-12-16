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
        String newBio = "Updated by Selenium at " + System.currentTimeMillis();
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
        String testMsg = "Hello" + System.currentTimeMillis();
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
}
