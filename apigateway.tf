resource "aws_api_gateway_rest_api" "hello-api" {
  name = "hello-api"
}

resource "aws_api_gateway_resource" "hello-resource" {
  rest_api_id = aws_api_gateway_rest_api.hello-api.id
  parent_id   = aws_api_gateway_rest_api.hello-api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello-method" {
  rest_api_id   = aws_api_gateway_rest_api.hello-api.id
  resource_id   = aws_api_gateway_resource.hello-resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello-integration" {
  rest_api_id             = aws_api_gateway_rest_api.hello-api.id
  http_method             = aws_api_gateway_method.hello-method.http_method
  type                    = "AWS_PROXY"
  resource_id             = aws_api_gateway_resource.hello-resource.id
  integration_http_method = "POST"
  uri                     = aws_lambda_function.terraform_lambda_func.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  source_arn    = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.hello-api.id}/*/${aws_api_gateway_method.hello-method.http_method}${aws_api_gateway_resource.hello-resource.path}"
}

resource "aws_api_gateway_deployment" "hello-deployment" {
  rest_api_id = aws_api_gateway_rest_api.hello-api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.hello-api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.hello-method, aws_api_gateway_integration.hello-integration]
}

resource "aws_api_gateway_stage" "hello-stage" {
  deployment_id = aws_api_gateway_deployment.hello-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.hello-api.id
  stage_name    = "dev"
}
