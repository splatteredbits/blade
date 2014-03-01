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
