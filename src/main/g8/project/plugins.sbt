resolvers += Resolver.url("hmrc-sbt-plugin-releases", url("https://dl.bintray.com/hmrc/sbt-plugin-releases"))(
  Resolver.ivyStylePatterns
)

addSbtPlugin("uk.gov.hmrc" % "sbt-auto-build" % "2.10.0")

addSbtPlugin("io.gatling" % "gatling-sbt" % "2.2.2")

addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.4.0")
