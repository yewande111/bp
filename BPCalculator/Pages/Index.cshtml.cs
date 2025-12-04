using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using System;

// page model

namespace BPCalculator.Pages
{
    public class BloodPressureModel : PageModel
    {
        private readonly ILogger<BloodPressureModel> _logger;

        public BloodPressureModel(ILogger<BloodPressureModel> logger)
        {
            _logger = logger;
        }

        [BindProperty]                              // bound on POST
        public BloodPressure BP { get; set; }

        // setup initial data
        public void OnGet()
        {
            BP = new BloodPressure() { Systolic = 100, Diastolic = 60 };
            _logger.LogInformation("Blood Pressure Calculator page loaded with default values");
        }

        // POST, validate
        public IActionResult OnPost()
        {
            _logger.LogInformation("BP calculation requested - Systolic: {Systolic}, Diastolic: {Diastolic}", 
                BP.Systolic, BP.Diastolic);

            // extra validation
            if (!(BP.Systolic > BP.Diastolic))
            {
                _logger.LogWarning("Invalid BP input - Systolic ({Systolic}) must be greater than Diastolic ({Diastolic})", 
                    BP.Systolic, BP.Diastolic);
                ModelState.AddModelError("", "Systolic must be greater than Diastolic");
                return Page();
            }

            try
            {
                var category = BP.Category;
                _logger.LogInformation("BP calculation successful - Systolic: {Systolic}, Diastolic: {Diastolic}, Category: {Category}", 
                    BP.Systolic, BP.Diastolic, category);
            }
            catch (ArgumentOutOfRangeException ex)
            {
                _logger.LogWarning(ex, "BP calculation failed - Out of range values: Systolic: {Systolic}, Diastolic: {Diastolic}", 
                    BP.Systolic, BP.Diastolic);
                ModelState.AddModelError("", ex.Message);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "BP calculation failed - Invalid values: Systolic: {Systolic}, Diastolic: {Diastolic}", 
                    BP.Systolic, BP.Diastolic);
                ModelState.AddModelError("", ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during BP calculation - Systolic: {Systolic}, Diastolic: {Diastolic}", 
                    BP.Systolic, BP.Diastolic);
                ModelState.AddModelError("", "An unexpected error occurred");
            }

            return Page();
        }
    }
}