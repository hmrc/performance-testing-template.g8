import sbt._

object Dependencies {

  val test = Seq(
    "uk.gov.hmrc"          %% "performance-test-runner"   % "5.8.0"         % Test
  )

}
