# Instructions to Run JMeter Tests for Backend Spring Boot Application

## Prerequisites
- Apache JMeter installed on your machine.
- Java Development Kit (JDK) installed.
- Maven installed for managing dependencies.

## Running the Tests
1. Open JMeter.
2. Load the test plan:
   - Go to `File` > `Open` and select `EdenMind_Test_Plan.jmx`.
3. Configure the test plan:
   - Ensure that the HTTP requests are correctly set up to point to your Spring Boot application's endpoints.
   - Adjust the thread groups as necessary to simulate the desired load.
4. Load test data:
   - Place `users.csv` and `emotion_logs.csv` in the appropriate directory as specified in the test plan.
5. Run the test:
   - Click on the green start button to begin the test execution.

## Interpreting Results
- View the results in the `View Results Tree` listener to analyze the responses from your application.
- Check the `Summary Report` for an overview of the test performance, including response times and throughput.

## Additional Notes
- Ensure your Spring Boot application is running before executing the tests.
- Modify the test plan as needed to cover different scenarios and endpoints.