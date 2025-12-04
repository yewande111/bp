using Xunit;
using TechTalk.SpecFlow;
using BPCalculator;

namespace BPCalculator.Tests.StepDefinitions
{
    [Binding]
    public class BloodPressureSteps
    {
        private BloodPressure? _bloodPressure;
        private BPCategory? _result;
        private Exception? _exception;

        [Given(@"I have a blood pressure calculator")]
        public void GivenIHaveABloodPressureCalculator()
        {
            // Background step - no action needed
        }

        [Given(@"systolic pressure is (.*)")]
        public void GivenSystolicPressureIs(int systolic)
        {
            if (_bloodPressure == null)
            {
                _bloodPressure = new BloodPressure { Systolic = systolic };
            }
            else
            {
                _bloodPressure.Systolic = systolic;
            }
        }

        [Given(@"diastolic pressure is (.*)")]
        public void GivenDiastolicPressureIs(int diastolic)
        {
            if (_bloodPressure == null)
            {
                _bloodPressure = new BloodPressure { Diastolic = diastolic };
            }
            else
            {
                _bloodPressure.Diastolic = diastolic;
            }
        }

        [When(@"I calculate the blood pressure category")]
        public void WhenICalculateTheBloodPressureCategory()
        {
            try
            {
                Assert.NotNull(_bloodPressure);
                _result = _bloodPressure.Category;
                _exception = null;
            }
            catch (Exception ex)
            {
                _exception = ex;
                _result = null;
            }
        }

        [Then(@"the result should be ""(.*)""")]
        public void ThenTheResultShouldBe(string expectedCategory)
        {
            Assert.Null(_exception);
            Assert.NotNull(_result);
            
            var expected = Enum.Parse<BPCategory>(expectedCategory);
            Assert.Equal(expected, _result.Value);
        }

        [Then(@"an error should occur with message ""(.*)""")]
        public void ThenAnErrorShouldOccurWithMessage(string expectedMessage)
        {
            Assert.NotNull(_exception);
            Assert.Contains(expectedMessage, _exception.Message);
        }
    }
}
