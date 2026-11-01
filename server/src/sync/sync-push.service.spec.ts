import { scrub } from './sync-push.service';

describe('scrub', () => {
  it('drops secret-looking keys at any depth and keeps the rest', () => {
    expect(
      scrub({
        staffId: 's1',
        pin: '1234',
        nested: {
          offlinePinVerifier: 'x',
          note: 'ok',
          list: [{ token: 't', n: 1 }],
        },
        Password: 'p',
      }),
    ).toEqual({ staffId: 's1', nested: { note: 'ok', list: [{ n: 1 }] } });
  });
});
