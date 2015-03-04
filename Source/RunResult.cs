/*
 * Copyright 2012 - 2014 Aaron Jensen
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
using System;
using System.Collections.Generic;

namespace Blade
{
    public sealed class RunResult
    {
        public RunResult(string name, IEnumerable<TestResult> results, int numIgnored)
        {
	        Name = name;
            Passed = new List<TestResult>();
            Failures = new List<TestResult>();
            Errors = new List<TestResult>();
            IgnoredCount = numIgnored;
            Duration = TimeSpan.Zero;
            Count = 0;

            if (results == null)
            {
                return;
            }

            foreach (var result in results)
            {
                Count++;

                if (result.Passed)
                {
                    Passed.Add(result);
                }

                if (result.Failure != null)
                {
                    Failures.Add(result);
                }

                if (result.Error != null)
                {
                    Errors.Add(result);
                }

                Duration += result.Duration;
            }
        }

        public int Count { get; private set; }
		public string Name { get; private set; }
        public IList<TestResult> Passed { get; private set; }
        public IList<TestResult> Failures { get; private set; }
        public IList<TestResult> Errors { get; private set; }
        public int IgnoredCount { get; private set; }
        public TimeSpan Duration { get; private set; }

        public override string ToString()
        {
            return string.Format(
                "Ran {0} tests{1} with {2} failure{3}, {4} error{5}, and {6} ignored in {7:0} second{8}.",
                Count,
                Count == 1 ? "" : "(s)",
                Failures.Count,
                Failures.Count == 1 ? "" : "s",
                Errors.Count,
                Errors.Count == 1 ? "" : "s",
                IgnoredCount,
                Duration.TotalSeconds,
                Duration.TotalSeconds >= 1.0 && Duration.TotalSeconds < 2.0 ? "" : "s"
                );
        }
    }
}
