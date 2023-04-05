# Test for OPENJDK-1549

<https://issues.redhat.com/browse/OPENJDK-1549>

This is a minimal Maven project for which the `validate` target will fail
if the environment variable `MAVEN_ARGS` is defined.

This is achieved using the Enforcer plugin. We could not use the
`requireEnvironmentVariable` built-in rule as it can only fail if a variable
is undefined, rather than if it is. Instead we use `evaluateBeanshell` and
a very short Beanshell expression.

Maven expands strings of the form `${env.foo}` within the POM only if the
variable is defined. That is, when `MAVEN_ARGS` is not defined in the
environment, the string `${env.MAVEN_ARGS}` is passed through unaltered.
If the variable is defined (including defined but empty), Maven will expand
it. Some string concatenation trickery is needed to match against the
un-expanded form.
