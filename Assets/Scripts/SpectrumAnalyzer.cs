using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class SpectrumAnalyzer : MonoBehaviour 
{

    [SerializeField] private Transform _capsule;

    public int resolution = 1024;
    public float lowFreqThreshold = 14700, midFreqThreshold = 29400, highFreqThreshold = 44100;
    public float lowEnhance = 1f, midEnhance = 10f, highEnhance = 100f;

    private AudioSource audio_;

    void Start()
    {
        audio_ = GetComponent<AudioSource>();

        audio_.clip = Microphone.Start(null, true, 10, 44100);
        // マイクが Ready になるまで待機（一瞬）
        while (Microphone.GetPosition(null) <= 0) {}

        audio_.Play();
    }

    void Update() {
        var spectrum = audio_.GetSpectrumData(resolution, 0, FFTWindow.BlackmanHarris);
        
        var deltaFreq = AudioSettings.outputSampleRate / resolution;
        float low = 0f, mid = 0f, high = 0f;
        
        for (var i = 0; i < resolution; ++i) {
            var freq = deltaFreq * i;
            if      (freq <= lowFreqThreshold)  low  += spectrum[i];
            else if (freq <= midFreqThreshold)  mid  += spectrum[i];
            else if (freq <= highFreqThreshold) high += spectrum[i];
        }

        low  *= lowEnhance;
        mid  *= midEnhance;
        high *= highEnhance;

        _capsule.localScale = new Vector3(high*50, mid*50, low*50);
    }
}