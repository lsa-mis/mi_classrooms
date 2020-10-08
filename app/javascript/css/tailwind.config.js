const defaultTheme = require('tailwindcss/defaultTheme')
module.exports = {
  theme: {
    extend: {spacing: {
      '1/2': '50%',
      '1/3': '33.333333%',
      '2/3': '66.666667%',
      '1/4': '25%',
      '2/4': '50%',
      '3/4': '75%',
      '1/5': '20%',
      '2/5': '40%',
      '3/5': '60%',
      '4/5': '80%',
      '1/6': '16.666667%',
      '2/6': '33.333333%',
      '3/6': '50%',
      '4/6': '66.666667%',
      '5/6': '83.333333%',
      '1/12': '8.333333%',
      '2/12': '16.666667%',
      '3/12': '25%',
      '4/12': '33.333333%',
      '5/12': '41.666667%',
      '6/12': '50%',
      '7/12': '58.333333%',
      '8/12': '66.666667%',
      '9/12': '75%',
      '10/12': '83.333333%',
      '11/12': '91.666667%',

      '72': '18rem',
      '84': '21rem',
      '96': '24rem',
      '108': '27rem'

    }},
    inset: {
      '0': 0,
      '12': '12%',
      '16': '16%',
      '20': '20%',
      '24': '24%',
      '30': '30%',
      '32': '32%',

      '1/2': '50%',
      '1/3': '33.333333%',
      '2/3': '66.666667%',
      '1/4': '25%',
      '2/4': '50%',
      '3/4': '75%',
      '1/5': '20%',
      '2/5': '40%',
      '3/5': '60%',
      '4/5': '80%',
      '1/6': '16.666667%',
      '2/6': '33.333333%',
      '3/6': '50%',
      '4/6': '66.666667%',
      '5/6': '83.333333%',
      '1/12': '8.333333%',
      '2/12': '16.666667%',
      '3/12': '25%',
      '4/12': '33.333333%',
      '5/12': '41.666667%',
      '6/12': '50%',
      '7/12': '58.333333%',
      '8/12': '66.666667%',
      '9/12': '75%',
      '10/12': '83.333333%',
      '11/12': '91.666667%'
    },
    colors: {

      transparent: 'transparent',

      black: '#000',
      white: '#fff',

      gray: {
        100: '#f7fafc',
        200: '#edf2f7',
        300: '#e2e8f0',
        400: '#cbd5e0',
        500: '#a0aec0',
        600: '#718096',
        700: '#4a5568',
        800: '#2d3748',
        900: '#1a202c',
      },
      red: {
        100: '#fff5f5',
        200: '#fed7d7',
        300: '#feb2b2',
        400: '#fc8181',
        500: '#f56565',
        600: '#e53e3e',
        700: '#c53030',
        800: '#9b2c2c',
        900: '#742a2a',
      },
      orange: {
        100: '#fffaf0',
        200: '#feebc8',
        300: '#fbd38d',
        400: '#f6ad55',
        500: '#ed8936',
        600: '#dd6b20',
        700: '#c05621',
        800: '#9c4221',
        900: '#7b341e',
      },
      yellow: {
        100: '#fffff0',
        200: '#fefcbf',
        300: '#faf089',
        400: '#f6e05e',
        500: '#ecc94b',
        600: '#d69e2e',
        700: '#b7791f',
        800: '#975a16',
        900: '#744210',
      },
      green: {
        100: '#f0fff4',
        200: '#c6f6d5',
        300: '#9ae6b4',
        400: '#68d391',
        500: '#48bb78',
        600: '#38a169',
        700: '#2f855a',
        800: '#276749',
        900: '#22543d',
      },

      blue: {
        100: '#ebf8ff',
        200: '#bee3f8',
        300: '#90cdf4',
        400: '#63b3ed',
        500: '#4299e1',
        600: '#3182ce',
        700: '#2b6cb0',
        800: '#2c5282',
        // 900: '#2a4365',
        900: '#00274c',
      },
      indigo: {
        100: '#ebf4ff',
        200: '#c3dafe',
        300: '#a3bffa',
        400: '#7f9cf5',
        500: '#667eea',
        600: '#5a67d8',
        700: '#4c51bf',
        800: '#434190',
        900: '#3c366b',
      },
      purple: {
        100: '#faf5ff',
        200: '#e9d8fd',
        300: '#d6bcfa',
        400: '#b794f4',
        500: '#9f7aea',
        600: '#805ad5',
        700: '#6b46c1',
        800: '#553c9a',
        900: '#44337a',
      },
      pink: {
        100: '#fff5f7',
        200: '#fed7e2',
        300: '#fbb6ce',
        400: '#f687b3',
        500: '#ed64a6',
        600: '#d53f8c',
        700: '#b83280',
        800: '#97266d',
        900: '#702459',
      },
    },
    customForms: theme => ({
      default: {
        label: {
          borderRadius: theme('borderRadius.lg'),
          backgroundColor: theme('colors.gray.200'),
          display: 'none',
          '&:focus': {
            backgroundColor: theme('colors.white'),
          }
        },

        'input, textarea, select, multiselect, checkbox, radio': {
          backgroundColor: theme('colors.blue.100'),
          borderColor: theme('colors.blue.200'),
          borderRadius: defaultTheme.borderRadius.default,

          '&::placeholder': {
            color: defaultTheme.colors.gray[600],
            opacity: '1',
          },
          '&:focus': {
            backgroundColor: theme('colors.yellow.100'),
            outline: 'none',
            boxShadow: defaultTheme.boxShadow.outline,
            borderColor: defaultTheme.colors.blue[400],
          },
        },
        checkbox: {
          width: theme('spacing.6'),
          height: theme('spacing.6'),
          '&:checked': {
            iconColor:  theme('colors.yellow.500'),
          },
        },
        select: {
          color: defaultTheme.colors.gray[600],
          opacity: '1',
          '&:focus': {
          },
        }
        // textarea: {
        //   appearance: 'none',
        //   borderColor: defaultTheme.borderColor.default,
        //   borderWidth: defaultTheme.borderWidth.default,
        //   borderRadius: defaultTheme.borderRadius.default,
        //   paddingTop: defaultTheme.spacing[2],
        //   paddingRight: defaultTheme.spacing[3],
        //   paddingBottom: defaultTheme.spacing[2],
        //   paddingLeft: defaultTheme.spacing[3],
        //   fontSize: defaultTheme.fontSize.base,
        //   lineHeight: defaultTheme.lineHeight.normal,
        //   '&::placeholder': {
        //     color: defaultTheme.colors.gray[500],
        //     opacity: '1',
        //   },
        //   '&:focus': {
        //     outline: 'none',
        //     boxShadow: defaultTheme.boxShadow.outline,
        //     borderColor: defaultTheme.colors.blue[400],
        //   },
        // },
      }
    })


  },
  variants: {
    // Some useful comment
  },
  plugins: [
    require('@tailwindcss/custom-forms')
  ]
}
