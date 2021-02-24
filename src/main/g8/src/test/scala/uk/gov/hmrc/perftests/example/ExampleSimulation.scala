/*
 * Copyright 2020 HM Revenue & Customs
 *
 */

package uk.gov.hmrc.perftests.example

import io.gatling.core.Predef._
import io.gatling.core.action.builder.PauseBuilder
import uk.gov.hmrc.performance.simulation.PerformanceTestRunner
import uk.gov.hmrc.perftests.example.ExampleRequests._

import scala.concurrent.duration.DurationInt

class ExampleSimulation extends PerformanceTestRunner {

  setup("home-page", "Home Page") withRequests navigateToHomePage

  setup("post-vat-return-period", "Post vat return period") withRequests postVatReturnPeriod

  val pause = new PauseBuilder(5 milliseconds, None)

  setup("get-turnover-page", "Get turnover page") withActions(pause, getTurnoverPage)

  runSimulation()
}
