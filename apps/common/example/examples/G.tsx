import React, {useEffect, useState} from 'react';
import {Circle, G, Line, Rect, Svg, Text, Use} from 'react-native-svg';

const GExample = () => {
  const [fill, setFill] = useState('purple');

  useEffect(() => {
    let mounted = true;

    const timer = setTimeout(() => {
      if (mounted) {
        setFill('#856');
      }
    }, 2000);

    return () => {
      mounted = false;
      clearTimeout(timer);
    };
  }, []);

  return (
    <Svg height="100" width="100">
      <G fill={fill} stroke="pink" strokeWidth="3">
        <Circle cx="25" cy="25" r="11" />
        <Circle cx="25" cy="75" r="11" stroke="red" />
        <Circle cx="50" cy="50" r="11" fill="green" />
        <Circle cx="75" cy="25" r="11" stroke="red" />
        <Circle cx="75" cy="75" r="11" />
      </G>
    </Svg>
  );
};

GExample.title = 'G children props inherit';

function GTransform() {
  return (
    <Svg height="100" width="200">
      <G rotation="50" origin="40, 30" id="group">
        <Line x1="60" y1="10" x2="140" y2="10" stroke="#060" strokeWidth="1" />
        <Rect
          x="60"
          y="20"
          height="50"
          width="80"
          stroke="#060"
          strokeWidth="1"
          fill="#060"
        />
        <Text
          x="100"
          y="75"
          stroke="#600"
          strokeWidth="1"
          fill="#600"
          textAnchor="middle">
          Text grouped with shapes
        </Text>
      </G>
      <Use
        href="#group"
        x="5"
        y="40"
        rotation="-50"
        scale="0.75"
        stroke="red"
        opacity="0.5"
      />
    </Svg>
  );
}
GTransform.title = 'G transform';

const icon = (
  <Svg height="30" width="30" viewBox="0 0 20 20">
    <G fill="purple" stroke="pink" strokeWidth="1">
      <Circle cx="5" cy="5" r="3" />
      <Circle cx="5" cy="15" r="3" />
      <Circle cx="10" cy="10" fill="green" r="3" />
      <Circle cx="15" cy="5" r="3" />
      <Circle cx="15" cy="15" r="3" />
    </G>
  </Svg>
);
const samples = [GExample, GTransform];

export {icon, samples};
