using UnityEngine;
using System.Collections;

public class AnimationGIF : MonoBehaviour {

    public Material material;
    public float changeFrameSecond;
    public string folderName;
    public string headText;
    public int imageLength;
    private int firstFrameNum;
    private float dTime;

    // Use this for initialization
    void Start () {
        firstFrameNum = 0;
        dTime = 0.0f;
    }

    // Update is called once per frame
    void Update () {
        dTime += Time.deltaTime;
        if (changeFrameSecond < dTime) {
            dTime = 0.0f;
            firstFrameNum++;
            if(firstFrameNum > imageLength) firstFrameNum = 0;
        }
        Texture tex = Resources.Load(folderName + "/" + headText + firstFrameNum) as Texture;
        material.SetTexture ("_MainTex", tex);
    }

}