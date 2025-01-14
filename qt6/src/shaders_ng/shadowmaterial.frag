// SPDX-FileCopyrightText: 2023 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: LGPL-3.0-or-later

#version 440

layout(location = 0) in vec4 qt_VertexPosition;
layout(location = 1) in vec2 qt_VertexTexCoord;
layout(location = 2) in vec2 qt_TexCoord;

layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 color;
    float relativeSizeX;
    float relativeSizeY;
    float spread;
} ubuf;

highp float linearstep(highp float e0, highp float e1, highp float x) {
    return clamp((x - e0) / (e1 - e0), 0.0, 1.0);
}
void main() {
    lowp float alpha =
        smoothstep(0.0, ubuf.relativeSizeX, 0.5 - abs(0.5 - qt_TexCoord.x)) *
        smoothstep(0.0, ubuf.relativeSizeY, 0.5 - abs(0.5 - qt_TexCoord.y));
    highp float spreadMultiplier = linearstep(ubuf.spread, 1.0 - ubuf.spread, alpha);
    fragColor = ubuf.color * ubuf.qt_Opacity * spreadMultiplier * spreadMultiplier;
}
