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
using System.Management.Automation;

namespace Blade
{
    public sealed class TestResult
    {
        public TestResult(string fixtureName, string name)
        {
            FixtureName = fixtureName;
            Name = name;
            Passed = false;
            Failure = null;
            Error = null;
            StartedAt = DateTime.Now;
            Output = new List<object>();
        }

        public string FixtureName { get; private set; }
        public string Name { get; private set; }
        public bool Passed { get; private set; }
        public AssertionException Failure { get; private set; }
        public ErrorRecord Error { get; private set; }
        public TimeSpan Duration { get; private set; }
        public DateTime StartedAt { get; private set; }
        public IList<object> Output { get; private set; }

        public void Completed()
        {
            Passed = true;
            Duration = DateTime.Now - StartedAt;
        }

        public void Completed(AssertionException ex)
        {
            Completed();
            Passed = false;
            Failure = ex;
        }

        public void Completed(ErrorRecord error)
        {
            Completed();
            Passed = false;
            Error = error;
        }
    }
}
