using System;
using System.ComponentModel.DataAnnotations;
using System.Diagnostics;

namespace BPCalculator
{
    // BP categories
    public enum BPCategory
    {
        [Display(Name="Low Blood Pressure")] Low,
        [Display(Name="Ideal Blood Pressure")]  Ideal,
        [Display(Name="Pre-High Blood Pressure")] PreHigh,
        [Display(Name ="High Blood Pressure")]  High
    };

    public class BloodPressure
    {
        public const int SystolicMin = 70;
        public const int SystolicMax = 190;
        public const int DiastolicMin = 40;
        public const int DiastolicMax = 100;

        [Range(SystolicMin, SystolicMax, ErrorMessage = "Invalid Systolic Value")]
        public int Systolic { get; set; }                       // mmHG

        [Range(DiastolicMin, DiastolicMax, ErrorMessage = "Invalid Diastolic Value")]
        public int Diastolic { get; set; }                      // mmHG

        // calculate BP category
        public BPCategory Category
        {
            get
            {
                // Validation: Systolic must be greater than Diastolic
                if (Systolic <= Diastolic)
                {
                    throw new ArgumentException("Systolic pressure must be greater than diastolic pressure");
                }

                // Validation: Check if values are within valid ranges
                if (Systolic < SystolicMin || Systolic > SystolicMax)
                {
                    throw new ArgumentOutOfRangeException(nameof(Systolic), 
                        $"Systolic pressure must be between {SystolicMin} and {SystolicMax}");
                }

                if (Diastolic < DiastolicMin || Diastolic > DiastolicMax)
                {
                    throw new ArgumentOutOfRangeException(nameof(Diastolic), 
                        $"Diastolic pressure must be between {DiastolicMin} and {DiastolicMax}");
                }

                // Blood Pressure Classification
                // Based on standard medical guidelines and assignment chart
                
                // High Blood Pressure: Systolic >= 140 OR Diastolic >= 90
                if (Systolic >= 140 || Diastolic >= 90)
                {
                    return BPCategory.High;
                }

                // Pre-High Blood Pressure: Systolic 120-139 OR Diastolic 80-89
                if ((Systolic >= 120 && Systolic <= 139) || (Diastolic >= 80 && Diastolic <= 89))
                {
                    return BPCategory.PreHigh;
                }

                // Ideal Blood Pressure: Systolic 90-119 AND Diastolic 60-79
                if (Systolic >= 90 && Systolic <= 119 && Diastolic >= 60 && Diastolic <= 79)
                {
                    return BPCategory.Ideal;
                }

                // Low Blood Pressure: Systolic < 90 OR Diastolic < 60
                return BPCategory.Low;
            }
        }

        // Get user-friendly explanation for BP category
        public static string GetCategoryExplanation(BPCategory category)
        {
            return category switch
            {
                BPCategory.Low => 
                    "Your blood pressure is low. If you experience dizziness, weakness, or fatigue, " +
                    "please consult a healthcare provider.",
                
                BPCategory.Ideal => 
                    "Your blood pressure is ideal and healthy. Keep maintaining your current lifestyle " +
                    "with regular exercise and a balanced diet.",
                
                BPCategory.PreHigh => 
                    "Your blood pressure is pre-high (prehypertension). Consider lifestyle changes such as " +
                    "reducing salt intake, exercising regularly, and managing stress.",
                
                BPCategory.High => 
                    "Your blood pressure is high. Please consult a healthcare provider for proper evaluation " +
                    "and treatment. Monitor your BP regularly.",
                
                _ => 
                    "Unable to determine category. Please ensure valid input values."
            };
        }
    }
}
