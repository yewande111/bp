using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace BPCalculator
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureLogging(logging =>
                {
                    // Add console logging for local development
                    logging.AddConsole();
                    
                    // Add AWS CloudWatch logging
                    // This will automatically work when deployed to Elastic Beanstalk
                    logging.AddAWSProvider();
                })
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                    // Configure to listen on all network interfaces for Elastic Beanstalk
                    webBuilder.UseUrls("http://0.0.0.0:5000");
                });
    }
}
//
