<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="app.diagrams.net" modified="2025-12-04T00:00:00.000Z" agent="python" etag="12345" version="20.4.1" type="device">
  <diagram id="diagram1" name="Architecture">
    <mxGraphModel dx="827" dy="516" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <mxCell id="vpc" value="VPC" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1f5fe;" vertex="1" parent="1">
          <mxGeometry x="20" y="20" width="760" height="460" as="geometry"/>
        </mxCell>
        <mxCell id="alb" value="ALB" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fff59d;" vertex="1" parent="vpc">
          <mxGeometry x="50" y="40" width="200" height="60" as="geometry"/>
        </mxCell>
        <mxCell id="asg" value="Auto Scaling Group
(Private Subnets)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#c8e6c9;" vertex="1" parent="vpc">
          <mxGeometry x="50" y="120" width="300" height="160" as="geometry"/>
        </mxCell>
        <mxCell id="rds" value="RDS / Aurora (Private)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#d1c4e9;" vertex="1" parent="vpc">
          <mxGeometry x="380" y="120" width="220" height="120" as="geometry"/>
        </mxCell>
        <mxCell id="cache" value="ElastiCache (Redis)" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#ffe0b2;" vertex="1" parent="vpc">
          <mxGeometry x="380" y="260" width="220" height="80" as="geometry"/>
        </mxCell>
        <mxCell id="cloudwatch" value="CloudWatch / Logs" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f0f4c3;" vertex="1" parent="vpc">
          <mxGeometry x="50" y="300" width="200" height="80" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>