using System;
using Xunit;
using BPCalculator;

namespace BPCalculator.Tests
{
    public class BloodPressureTests
    {
        #region Low Blood Pressure Tests

        [Fact]
        public void Category_SystolicLow_ReturnsLow()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 85, Diastolic = 55 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Low, category);
        }

        [Fact]
        public void Category_DiastolicLow_ReturnsLow()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 100, Diastolic = 55 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Low, category);
        }

        [Fact]
        public void Category_BothLow_ReturnsLow()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 85, Diastolic = 50 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Low, category);
        }

        #endregion

        #region Ideal Blood Pressure Tests

        [Fact]
        public void Category_IdealBloodPressure_ReturnsIdeal()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 115, Diastolic = 75 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Ideal, category);
        }

        [Fact]
        public void Category_LowerIdealBoundary_ReturnsIdeal()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 90, Diastolic = 60 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Ideal, category);
        }

        [Fact]
        public void Category_UpperIdealBoundary_ReturnsIdeal()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 119, Diastolic = 79 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Ideal, category);
        }

        #endregion

        #region Pre-High Blood Pressure Tests

        [Fact]
        public void Category_PreHighBloodPressure_ReturnsPreHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 130, Diastolic = 85 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.PreHigh, category);
        }

        [Fact]
        public void Category_LowerPreHighBoundary_ReturnsPreHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 120, Diastolic = 75 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.PreHigh, category);
        }

        [Fact]
        public void Category_UpperPreHighBoundary_ReturnsPreHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 139, Diastolic = 89 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.PreHigh, category);
        }

        [Fact]
        public void Category_PreHighDiastolic_ReturnsPreHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 110, Diastolic = 85 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.PreHigh, category);
        }

        #endregion

        #region High Blood Pressure Tests

        [Fact]
        public void Category_HighBloodPressure_ReturnsHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 150, Diastolic = 95 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.High, category);
        }

        [Fact]
        public void Category_SystolicHighBoundary_ReturnsHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 140, Diastolic = 75 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.High, category);
        }

        [Fact]
        public void Category_DiastolicHighBoundary_ReturnsHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 115, Diastolic = 90 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.High, category);
        }

        [Fact]
        public void Category_BothHigh_ReturnsHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 160, Diastolic = 100 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.High, category);
        }

        #endregion

        #region Boundary Value Tests

        [Fact]
        public void Category_Systolic89Diastolic59_ReturnsLow()
        {
            // Arrange: Just below ideal range
            var bp = new BloodPressure { Systolic = 89, Diastolic = 59 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Low, category);
        }

        [Fact]
        public void Category_Systolic120Diastolic79_ReturnsPreHigh()
        {
            // Arrange: Boundary between ideal and pre-high
            var bp = new BloodPressure { Systolic = 120, Diastolic = 79 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.PreHigh, category);
        }

        [Fact]
        public void Category_Systolic119Diastolic80_ReturnsPreHigh()
        {
            // Arrange: Boundary between ideal and pre-high
            var bp = new BloodPressure { Systolic = 119, Diastolic = 80 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.PreHigh, category);
        }

        [Fact]
        public void Category_Systolic140Diastolic89_ReturnsHigh()
        {
            // Arrange: Boundary between pre-high and high
            var bp = new BloodPressure { Systolic = 140, Diastolic = 89 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.High, category);
        }

        [Fact]
        public void Category_Systolic139Diastolic90_ReturnsHigh()
        {
            // Arrange: Boundary between pre-high and high
            var bp = new BloodPressure { Systolic = 139, Diastolic = 90 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.High, category);
        }

        #endregion

        #region Validation Tests

        [Fact]
        public void Category_SystolicEqualsDiastolic_ThrowsArgumentException()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 100, Diastolic = 100 };

            // Act & Assert
            Assert.Throws<ArgumentException>(() => bp.Category);
        }

        [Fact]
        public void Category_SystolicLessThanDiastolic_ThrowsArgumentException()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 90, Diastolic = 100 };

            // Act & Assert
            Assert.Throws<ArgumentException>(() => bp.Category);
        }

        [Fact]
        public void Category_SystolicBelowMin_ThrowsArgumentOutOfRangeException()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 69, Diastolic = 60 };

            // Act & Assert
            Assert.Throws<ArgumentOutOfRangeException>(() => bp.Category);
        }

        [Fact]
        public void Category_SystolicAboveMax_ThrowsArgumentOutOfRangeException()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 191, Diastolic = 80 };

            // Act & Assert
            Assert.Throws<ArgumentOutOfRangeException>(() => bp.Category);
        }

        [Fact]
        public void Category_DiastolicBelowMin_ThrowsArgumentOutOfRangeException()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 100, Diastolic = 39 };

            // Act & Assert
            Assert.Throws<ArgumentOutOfRangeException>(() => bp.Category);
        }

        [Fact]
        public void Category_DiastolicAboveMax_ThrowsArgumentOutOfRangeException()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 150, Diastolic = 101 };

            // Act & Assert
            Assert.Throws<ArgumentOutOfRangeException>(() => bp.Category);
        }

        #endregion

        #region Edge Case Tests

        [Fact]
        public void Category_MinimumValidValues_ReturnsLow()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 70, Diastolic = 40 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.Low, category);
        }

        [Fact]
        public void Category_MaximumValidValues_ReturnsHigh()
        {
            // Arrange
            var bp = new BloodPressure { Systolic = 190, Diastolic = 100 };

            // Act
            var category = bp.Category;

            // Assert
            Assert.Equal(BPCategory.High, category);
        }

        #endregion
    }
}
