Feature: Blood Pressure Classification
    As a healthcare professional
    I want to classify blood pressure readings into categories
    So that I can quickly assess a patient's cardiovascular health status

Background:
    Given I have a blood pressure calculator

Scenario: Low blood pressure - Both values low
    Given systolic pressure is 85
    And diastolic pressure is 55
    When I calculate the blood pressure category
    Then the result should be "Low"

Scenario: Low blood pressure - Systolic low
    Given systolic pressure is 89
    And diastolic pressure is 65
    When I calculate the blood pressure category
    Then the result should be "Low"

Scenario: Low blood pressure - Diastolic low
    Given systolic pressure is 100
    And diastolic pressure is 59
    When I calculate the blood pressure category
    Then the result should be "Low"

Scenario: Ideal blood pressure - Mid range
    Given systolic pressure is 115
    And diastolic pressure is 75
    When I calculate the blood pressure category
    Then the result should be "Ideal"

Scenario: Ideal blood pressure - Lower boundary
    Given systolic pressure is 90
    And diastolic pressure is 60
    When I calculate the blood pressure category
    Then the result should be "Ideal"

Scenario: Ideal blood pressure - Upper boundary
    Given systolic pressure is 119
    And diastolic pressure is 79
    When I calculate the blood pressure category
    Then the result should be "Ideal"

Scenario: Pre-high blood pressure - Mid range
    Given systolic pressure is 130
    And diastolic pressure is 85
    When I calculate the blood pressure category
    Then the result should be "PreHigh"

Scenario: Pre-high blood pressure - Lower boundary
    Given systolic pressure is 120
    And diastolic pressure is 80
    When I calculate the blood pressure category
    Then the result should be "PreHigh"

Scenario: Pre-high blood pressure - Upper boundary
    Given systolic pressure is 139
    And diastolic pressure is 89
    When I calculate the blood pressure category
    Then the result should be "PreHigh"

Scenario: Pre-high blood pressure - Diastolic driven
    Given systolic pressure is 115
    And diastolic pressure is 85
    When I calculate the blood pressure category
    Then the result should be "PreHigh"

Scenario: High blood pressure - Both high
    Given systolic pressure is 150
    And diastolic pressure is 95
    When I calculate the blood pressure category
    Then the result should be "High"

Scenario: High blood pressure - Systolic boundary
    Given systolic pressure is 140
    And diastolic pressure is 85
    When I calculate the blood pressure category
    Then the result should be "High"

Scenario: High blood pressure - Diastolic boundary
    Given systolic pressure is 135
    And diastolic pressure is 90
    When I calculate the blood pressure category
    Then the result should be "High"

Scenario: High blood pressure - Very high values
    Given systolic pressure is 180
    And diastolic pressure is 100
    When I calculate the blood pressure category
    Then the result should be "High"

Scenario Outline: Blood pressure classification with multiple readings
    Given systolic pressure is <systolic>
    And diastolic pressure is <diastolic>
    When I calculate the blood pressure category
    Then the result should be "<category>"

    Examples:
    | systolic | diastolic | category |
    | 85       | 55        | Low      |
    | 100      | 70        | Ideal    |
    | 125      | 82        | PreHigh  |
    | 145      | 92        | High     |
    | 119      | 79        | Ideal    |
    | 120      | 80        | PreHigh  |
    | 140      | 85        | High     |

Scenario: Invalid blood pressure - Systolic less than diastolic
    Given systolic pressure is 80
    And diastolic pressure is 90
    When I calculate the blood pressure category
    Then an error should occur with message "Systolic pressure must be greater than diastolic pressure"

Scenario: Invalid blood pressure - Systolic too low
    Given systolic pressure is 65
    And diastolic pressure is 45
    When I calculate the blood pressure category
    Then an error should occur with message "Systolic pressure must be between 70 and 190"

Scenario: Invalid blood pressure - Systolic too high
    Given systolic pressure is 195
    And diastolic pressure is 85
    When I calculate the blood pressure category
    Then an error should occur with message "Systolic pressure must be between 70 and 190"

Scenario: Invalid blood pressure - Diastolic too low
    Given systolic pressure is 120
    And diastolic pressure is 35
    When I calculate the blood pressure category
    Then an error should occur with message "Diastolic pressure must be between 40 and 100"

Scenario: Invalid blood pressure - Diastolic too high
    Given systolic pressure is 150
    And diastolic pressure is 105
    When I calculate the blood pressure category
    Then an error should occur with message "Diastolic pressure must be between 40 and 100"

Scenario: Edge case - Minimum valid values
    Given systolic pressure is 70
    And diastolic pressure is 40
    When I calculate the blood pressure category
    Then the result should be "Low"

Scenario: Edge case - Maximum valid values
    Given systolic pressure is 190
    And diastolic pressure is 100
    When I calculate the blood pressure category
    Then the result should be "High"

Scenario Outline: Category explanation provides helpful information
    When I request an explanation for "<category>" category
    Then the explanation should contain "<keyword>"
    And the explanation should not be empty

    Examples:
    | category | keyword            |
    | Low      | dizziness          |
    | Ideal    | healthy            |
    | PreHigh  | lifestyle          |
    | High     | healthcare provider|
