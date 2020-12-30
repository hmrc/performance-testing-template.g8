import sbt._

object Dependencies {

  private val gatlingVersion = "2.3.1"

  val test = Seq(
    "com.typesafe"          % "config"                    % "1.3.1"        % Test,
    "uk.gov.hmrc"          %% "performance-test-runner"   % "3.10.0"        % Test,
    "io.gatling"            % "gatling-test-framework"    % gatlingVersion % Test,
    "io.gatling.highcharts" % "gatling-charts-highcharts" % gatlingVersion % Test
  )
}
